import re
import os
import sys
import copy
import shutil
import random
import subprocess
import clang.cindex


def remove_comments(_file):
    with open(_file, 'r') as file:
        text = file.read()

    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return " "
        else:
            return s

    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )

    with open(_file, 'w') as file:
        file.write(re.sub(pattern, replacer, text))


def get_clang_info(node, depth=0):
    children = [get_clang_info(c, depth + 1) for c in node.get_children()]

    start_info = str(node.extent.start).split(',')
    start_info = [int(start_info[1][6:]) - 1, int(start_info[2][8:-1]) - 1]
    end_info = str(node.extent.end).split(',')
    end_info = [int(end_info[1][6:]) - 1, int(end_info[2][8:-1]) - 1]

    return {'usr': node.get_usr(),
            'spelling': node.spelling,
            'start': start_info,
            'end': end_info,
            'is_definition': node.is_definition(),
            'children': children}


def get_source_code(start, end, data):
    if start[0] == end[0]:
        return data[start[0]][start[1]:end[1] + 1]
    else:
        temp = data[start[0]][start[1]:]
        i = start[0] + 1

        while i < end[0]:
            temp = temp + data[i]
            i = i + 1
        return temp + data[end[0]][:end[1] + 1]


def split_list(input_list, n):
    k, m = divmod(len(input_list), n)
    return [input_list[i * k + min(i, m):(i + 1) * k + min(i + 1, m)] for i in range(n) if (i * k + min(i, m)) < len(input_list)]


def test_partitions(partitions, test_function):
    for i, partition in enumerate(partitions):
        other_partitions = [p for j, p in enumerate(partitions) if j != i]
        reduced_input = [elem for sublist in other_partitions for elem in sublist]
        if test_function(reduced_input):
            return reduced_input
    return None

class PriorityQLearningAgent:
    def __init__(self, learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1):
        self.learning_rate = learning_rate
        self.discount_factor = discount_factor
        self.exploration_rate = exploration_rate
        self.q_values = {}

    def choose_action(self, state, actions):
        if random.random() < self.exploration_rate:
            return random.choice(actions)
        else:
            sorted_actions = sorted(actions, key=lambda action: self.q(state, action), reverse=True)
            return sorted_actions

    def learn(self, state, action, reward, next_state, actions):
        max_q = max(self.q(next_state, a) for a in actions)
        self.q_values[(state, action)] = self.q(state, action) + self.learning_rate * (reward + self.discount_factor * max_q - self.q(state, action))

    def q(self, state, action):
        return self.q_values.get((state, action), 0.0)


class RLDebloatDU:
    def __init__(self, path, program, oracle):
        self.code = []
        self.func = {}
        self.func_name = {}
        self.func_name2 = {}
        self.func_usage = {}
        self.glob = {}
        self.glob_name = {}
        self.local = {}
        self.local_name = {}
        self.def_lines = []
        self.assigns = {}
        self.func_added = set()
        self.func_call = set()
        self.du_chain_glob = {}
        self.du_chain_local = {}
        self.du_chain = {}
        self.du_bracket_defs = {}
        self.du_others = {}
        self.bracket = {}
        self.label = {}
        self.label_name = {}
        self.success = False
        self.original_code = []
        self.debloated_code = []

        big_flag = True
        iteration = 0
        while big_flag:
            big_flag = False
            iteration = iteration + 1
            print("Iteration: " + str(iteration))
            print("Function Reduction Started.")
            self.run()
            if self.success:
                big_flag = True
                with open(target_file, "w") as f:
                    f.writelines(self.debloated_code)
                self.generate_debloated_code(program)
            else:
                with open(target_file, "w") as f:
                    f.writelines(self.original_code)
            print("Global Variable Reduction Started.")
            self.run("global_variables")
            if self.success:
                big_flag = True
                with open(target_file, "w") as f:
                    f.writelines(self.debloated_code)
                self.generate_debloated_code(program)
            else:
                with open(target_file, "w") as f:
                    f.writelines(self.original_code)
            print("Global DU Chain Reduction Started.")
            self.run("du_chain_glob")
            if self.success:
                big_flag = True
                with open(target_file, "w") as f:
                    f.writelines(self.debloated_code)
                self.generate_debloated_code(program)
            else:
                with open(target_file, "w") as f:
                    f.writelines(self.original_code)
            print("Local Variable Reduction Started.")
            self.run("local_variables")
            if self.success:
                big_flag = True
                with open(target_file, "w") as f:
                    f.writelines(self.debloated_code)
                self.generate_debloated_code(program)
            else:
                with open(target_file, "w") as f:
                    f.writelines(self.original_code)
            print("Local DU Chain Reduction Started. -- code block")
            self.run("du_chain_local")
            if self.success:
                big_flag = True
                with open(target_file, "w") as f:
                    f.writelines(self.debloated_code)
                self.generate_debloated_code(program)
            else:
                with open(target_file, "w") as f:
                    f.writelines(self.original_code)

            print("Local DU Chain Reduction Started.")
            self.run("du_chain_local2")
            if self.success:
                big_flag = True
                with open(target_file, "w") as f:
                    f.writelines(self.debloated_code)
                self.generate_debloated_code(program)
            else:
                with open(target_file, "w") as f:
                    f.writelines(self.original_code)

    def run(self, debloat_type="functions"):
        self.format_source_code(target_file)
        self.visit_node(index.parse(target_file).cursor)
        self.original_code = self.code.copy()

        removed_items = []

        if debloat_type == "functions":
            kept_items = self.delta_debugging(debloat_type="functions")
            removed_items = [i for i in self.func.keys() if i not in kept_items]
        elif debloat_type == "global_variables":
            kept_items = self.delta_debugging(debloat_type="global_variables")
            removed_items = [i for i in self.glob.keys() if i not in kept_items]
        elif debloat_type == "du_chain_glob":
            kept_items = self.delta_debugging(debloat_type="du_chain_glob")
            removed_items = [i for i in self.du_chain_glob.keys() if i not in kept_items]
        elif debloat_type == "local_variables":
            removed_items = []
            for func_line in self.local:
                kept_local_vars = self.delta_debugging(debloat_type="local_variables", func_line=func_line)
                removed_local_vars = {k: v for k, v in self.local[func_line].items() if k not in kept_local_vars}
                removed_items.extend(removed_local_vars.keys())
        elif debloat_type == "du_chain_local":
            self.add_duchain_info()
            removed_items = []
            for func_line in self.du_bracket_defs:
                kept_local_vars = self.delta_debugging(debloat_type="du_chain_local", func_line=func_line)
                removed_items = [i for i in self.du_bracket_defs[func_line] if i not in kept_local_vars]
                removed_items.extend(kept_local_vars)
        elif debloat_type == "du_chain_local2":
            self.add_duchain_info()
            removed_items = []
            for func_line in self.du_others:
                kept_local_vars = self.delta_debugging(debloat_type="du_chain_local2", func_line=func_line)
                removed_items = [i for i in self.du_others[func_line] if i not in kept_local_vars]
                removed_items.extend(kept_local_vars)

        return removed_items

    def delta_debugging(self, debloat_type="functions", input_list=None, func_line=None):

        if input_list is None:
            if debloat_type == "functions":
                input_list = list(self.func.keys())
            if debloat_type == "global_variables":
                input_list = list(self.glob.keys())
            if debloat_type == "du_chain_glob":
                input_list = list(self.du_chain_glob.keys())
            if debloat_type == "local_variables":
                input_list = list(self.local[func_line].keys())
            if debloat_type == "du_chain_local":
                input_list = self.du_bracket_defs[func_line]
            if debloat_type == "du_chain_local2":
                input_list = self.du_others[func_line]
        print("Total Candidates: " + str(len(input_list)))

        def test_function(subset):
            return self.is_valid(subset, debloat_type, func_line)

        n = 2
        reduced_input = input_list
        agent = PriorityQLearningAgent(learning_rate=0.1, discount_factor=0.9, exploration_rate=0.1)

        while len(reduced_input) > 1:
            partitions = split_list(reduced_input, n)
            partition_actions = list(range(len(partitions)))
            state = (tuple(reduced_input), n)

            sorted_actions = sorted(partition_actions, key=lambda action: agent.q(state, action), reverse=True)
            new_reduced_input = None
            for action in sorted_actions:
                other_partitions = [partitions[i] for i in range(len(partitions)) if i != action]
                candidate_input = [elem for sublist in other_partitions for elem in sublist]

                if test_function(candidate_input):
                    print("Reduced Candidates: " + str(len(candidate_input)))
                    new_reduced_input = candidate_input
                    reward = len(reduced_input) - len(candidate_input)
                    break
                else:
                    reward = -1

                next_state = (tuple(reduced_input), n)
                agent.learn(state, action, reward, next_state, partition_actions)
                state = next_state

            if new_reduced_input is not None:
                reduced_input = new_reduced_input
                n = max(n // 2, 1)
            else:
                if n < len(reduced_input):
                    n *= 2
                else:
                    break

        return reduced_input

    def is_valid(self, kept_items, debloat_type, func_line=None):
        removed_lines = []

        if debloat_type == "functions":
            for func in self.func:
                if func not in kept_items:
                    removed_lines = self.remove_func(func, removed_lines)
        elif debloat_type == "global_variables":
            for glob_var in self.glob:
                if glob_var not in kept_items:
                    removed_lines = self.remove_global_variables(glob_var, removed_lines)
        elif debloat_type == "du_chain_glob":
            for du_chain_item in self.du_chain_glob:
                if du_chain_item not in kept_items:
                    removed_lines = self.remove_global_duchain(du_chain_item, removed_lines)
        elif debloat_type == "local_variables":
            removed_lines = self.remove_local(self.local[func_line], kept_items, removed_lines)
        elif debloat_type == "du_chain_local":
            removed_lines = self.remove_du_local(kept_items, func_line, removed_lines)
        elif debloat_type == "du_chain_local2":
            removed_lines = self.remove_du_local2(kept_items, func_line, removed_lines)

        with open(target_file, 'w') as file:
            file.writelines(self.code)


        valid = self.test(base_path)

        if valid:
            self.debloated_code = copy.deepcopy(self.code)
            self.success = True

        # Restore the removed code
        if self.success:
            self.code = copy.deepcopy(self.debloated_code)
        else:
            self.code = copy.deepcopy(self.original_code)

        return valid

    def remove_func(self, func, removed_lines):
        for line_num in range(func, self.func[func] + 1):
            if line_num not in removed_lines:
                self.code[line_num] = '//' + self.code[line_num]
                removed_lines.append(line_num)
        if func in self.func_usage:
            for ref_line in self.func_usage[func]:
                if ref_line in self.bracket:
                    removed_lines = self.remove_bracket(ref_line, removed_lines)
                elif ref_line in self.du_chain:
                    removed_lines = self.remove_line(ref_line, removed_lines)

                    for use in self.du_chain[ref_line]:
                        if use in self.bracket:
                            removed_lines = self.remove_bracket(use, removed_lines)
                        else:
                            removed_lines = self.remove_line(use, removed_lines)
                else:
                    removed_lines = self.remove_line(ref_line, removed_lines)

        return removed_lines

    def remove_line(self, line, removed_lines):
        if line not in removed_lines:
            self.code[line] = '//' + self.code[line]
            removed_lines.append(line)

            if line - 1 in self.label and ';\n' not in self.code[line - 1]:
                self.code[line - 1] = self.code[line - 1][:-1] + ';\n'
        return removed_lines

    def remove_global_variables(self, global_var, removed_lines):
        for var in self.glob[global_var]:
            if var in self.func:
                removed_lines = self.remove_func(var, removed_lines)
            elif var in self.bracket:
                removed_lines = self.remove_bracket(var, removed_lines)
            elif var in self.du_chain:
                for use in self.du_chain[var]:
                    if use in self.bracket:
                        removed_lines = self.remove_bracket(use, removed_lines)
                    elif use not in removed_lines:
                        removed_lines = self.remove_line(use, removed_lines)
            else:
                removed_lines = self.remove_line(var, removed_lines)

        return removed_lines

    def remove_global_duchain(self, global_var, removed_lines):
        for var in self.du_chain_glob[global_var]:
            if var in self.func:
                removed_lines = self.remove_func(var, removed_lines)
            elif var in self.bracket:
                removed_lines = self.remove_bracket(var, removed_lines)
            elif var in self.du_chain:
                for use in self.du_chain[var]:
                    if use in self.bracket:
                        removed_lines = self.remove_bracket(use, removed_lines)
                    elif use not in removed_lines:
                        removed_lines = self.remove_line(use, removed_lines)
            else:
                removed_lines = self.remove_line(var, removed_lines)

        return removed_lines

    def remove_local(self, local_vars, kept_items, removed_lines):
        for var_def_line, var_usage_lines in local_vars.items():
            if var_def_line not in kept_items:
                for var_line in var_usage_lines:
                    if var_line not in removed_lines:
                        if var_line in self.bracket:
                            removed_lines = self.remove_bracket(var_line, removed_lines)
                        else:
                            removed_lines = self.remove_line(var_line, removed_lines)
        return removed_lines

    def remove_du_local(self, kept_items, func_line, removed_lines):
        for var in self.du_bracket_defs[func_line]:
            if var not in kept_items:
                if var in self.du_chain_local[func_line]:
                    for var_line in self.du_chain_local[func_line][var]:
                        if var_line not in removed_lines:
                            if var_line in self.bracket:
                                removed_lines = self.remove_bracket(var_line, removed_lines)
                            elif var_line in self.label:
                                self.code[var_line] = '//' + self.code[var_line]
                                removed_lines.append(var_line)
                                for label_line in self.label[var_line]:
                                    if label_line not in removed_lines:
                                        self.code[label_line] = '//' + self.code[label_line]
                                        removed_lines.append(label_line)
                            else:
                                removed_lines = self.remove_line(var_line, removed_lines)
                elif var in self.bracket:
                    removed_lines = self.remove_bracket(var, removed_lines)
                elif var in self.label:
                    if var not in removed_lines:
                        self.code[var] = '//' + self.code[var]
                        removed_lines.append(var)
                    for label_line in self.label[var]:
                        if label_line not in removed_lines:
                            self.code[label_line] = '//' + self.code[label_line]
                            removed_lines.append(label_line)
                else:
                    removed_lines = self.remove_line(var, removed_lines)

    def remove_du_local2(self, kept_items, func_line, removed_lines):
        for var in self.du_others[func_line]:
            if var not in kept_items:
                if var in self.du_chain_local[func_line]:
                    for var_line in self.du_chain_local[func_line][var]:
                        if var_line not in removed_lines:
                            if var_line in self.bracket:
                                removed_lines = self.remove_bracket(var_line, removed_lines)
                            elif var_line in self.label:
                                self.code[var_line] = '//' + self.code[var_line]
                                removed_lines.append(var_line)
                                for label_line in self.label[var_line]:
                                    if label_line not in removed_lines:
                                        self.code[label_line] = '//' + self.code[label_line]
                                        removed_lines.append(label_line)
                            else:
                                removed_lines = self.remove_line(var_line, removed_lines)
                elif var in self.bracket:
                    removed_lines = self.remove_bracket(var, removed_lines)
                elif var in self.label:
                    if var not in removed_lines:
                        self.code[var] = '//' + self.code[var]
                        removed_lines.append(var)
                    for label_line in self.label[var]:
                        if label_line not in removed_lines:
                            self.code[label_line] = '//' + self.code[label_line]
                            removed_lines.append(label_line)
                else:
                    removed_lines = self.remove_line(var, removed_lines)

        return removed_lines

    def remove_bracket(self, line, removed_lines):
        for k in range(line, self.bracket[line] + 1):
            if k not in removed_lines:
                if k - 1 in self.label and ';\n' not in self.code[k - 1]:
                    self.code[k - 1] = self.code[k - 1][:-1] + ';\n'
                if k in self.label:
                    for label_line in self.label[k]:
                        self.code[label_line] = '//' + self.code[label_line]
                        removed_lines.append(label_line)
                self.code[k] = '//' + self.code[k]
                removed_lines.append(k)
        if self.bracket[line] + 1 in self.bracket:
            self.code[self.bracket[line] + 1] = self.code[self.bracket[line] + 1].replace("else ", "")
        return removed_lines

    def add_duchain_info(self):

        for func in self.du_chain_local:
            for du_def in self.du_chain_local[func]:
                for du_use in self.du_chain_local[func][du_def]:
                    if du_use in self.bracket:
                        if func in self.du_bracket_defs:
                            if du_def not in self.du_bracket_defs[func]:
                                self.du_bracket_defs[func].append(du_def)
                        else:
                            self.du_bracket_defs[func] = [du_def]
                        break

        for func in self.du_chain_local:
            for du_def in self.du_chain_local[func]:
                if func not in self.du_bracket_defs or du_def not in self.du_bracket_defs[func]:
                    if func in self.du_others:
                        self.du_others[func].append(du_def)
                    else:
                        self.du_others[func] = [du_def]

    def visit_node(self, node):
        line_number = node.location.line - 1
        code = re.sub(r'"[^"]*"', '', self.code[line_number])
        var_name = node.spelling
        func_line = self.is_in_function(line_number)

        if func_line:
            if func_line not in self.local_name:
                self.local_name[func_line] = {}
            if func_line not in self.du_chain_local:
                self.du_chain_local[func_line] = {}
            if node.kind == clang.cindex.CursorKind.CALL_EXPR:
                self.func_call.add(line_number)
            if node.kind == clang.cindex.CursorKind.VAR_DECL or node.kind == clang.cindex.CursorKind.PARM_DECL:
                self.local_name[func_line][var_name] = line_number

                if '>=' not in code and '<=' not in code and \
                        '==' not in code and '!=' not in code and \
                        '=' in code and line_number not in self.def_lines:
                    self.du_chain_local[func_line][line_number] = [line_number]
                    self.assigns[var_name] = line_number
                    self.def_lines.append(line_number)
                    self.du_chain[line_number] = [line_number]
                    self.func_added.add(line_number)
            elif node.kind == clang.cindex.CursorKind.DECL_REF_EXPR and var_name in self.local_name[func_line]:
                if func_line not in self.local:
                    self.local[func_line] = {}

                def_line = self.local_name[func_line][var_name]
                if def_line != line_number:
                    if def_line in self.local[func_line]:
                        if line_number not in self.local[func_line][def_line]:
                            self.local[func_line][def_line].append(line_number)
                    else:
                        self.local[func_line][def_line] = [line_number]

                if '>=' not in code and '<=' not in code and \
                        '==' not in code and '!=' not in code and \
                        '=' in code and line_number not in self.def_lines:
                    if func_line not in self.du_chain_local:
                        self.du_chain_local[func_line] = {}
                    self.du_chain_local[func_line][line_number] = [line_number]
                    self.func_added.add(line_number)
                    self.assigns[var_name] = line_number
                    self.def_lines.append(line_number)
                    self.du_chain[line_number] = [line_number]
                else:
                    if var_name in self.assigns:
                        if self.is_in_function(self.assigns[var_name]) == func_line:
                            if line_number not in self.du_chain_local[func_line][self.assigns[var_name]]:
                                self.du_chain_local[func_line][self.assigns[var_name]].append(line_number)
                                self.func_added.add(line_number)
                                self.du_chain[self.assigns[var_name]].append(line_number)
                        else:
                            self.assigns[var_name] = line_number
                            self.du_chain_local[func_line][line_number] = [line_number]
                            self.func_added.add(line_number)
                            self.du_chain[line_number] = [line_number]
                    else:
                        self.assigns[var_name] = line_number
                        self.du_chain_local[func_line][line_number] = [line_number]
                        self.func_added.add(line_number)
                        self.du_chain[line_number] = [line_number]
        else:
            if node.kind == clang.cindex.CursorKind.VAR_DECL:
                if '>=' not in code and '<=' not in code and \
                        '==' not in code and '!=' not in code and \
                        '=' in code and line_number not in self.def_lines:
                    self.du_chain_glob[line_number] = [line_number]
                    self.assigns[var_name] = line_number
                    self.def_lines.append(line_number)
                    self.du_chain[line_number] = [line_number]
                self.glob_name[var_name] = line_number
        if node.kind == clang.cindex.CursorKind.FUNCTION_DECL:
            self.label_name.clear()
        elif node.kind == clang.cindex.CursorKind.DECL_REF_EXPR and var_name in self.glob_name:
            def_line = self.glob_name[var_name]

            if def_line != line_number:
                if def_line in self.glob:
                    if line_number not in self.glob[def_line]:
                        self.glob[def_line].append(line_number)
                else:
                    self.glob[def_line] = [line_number]

            if '>=' not in code and '<=' not in code and \
                    '==' not in code and '!=' not in code and \
                    '=' in code and line_number not in self.def_lines:
                self.du_chain_glob[line_number] = [line_number]
                self.assigns[var_name] = line_number
                self.def_lines.append(line_number)
                self.du_chain[line_number] = [line_number]
            else:
                if var_name not in self.assigns:
                    self.assigns[var_name] = line_number
                    self.du_chain_glob[line_number] = [line_number]
                    self.du_chain[line_number] = [line_number]
                elif line_number not in self.du_chain_glob[self.assigns[var_name]]:
                    self.du_chain_glob[self.assigns[var_name]].append(line_number)
                    self.du_chain[self.assigns[var_name]].append(line_number)

        if node.kind == clang.cindex.CursorKind.LABEL_STMT:
            self.label_name[var_name] = line_number
            if var_name in self.label:
                self.label[line_number] = copy.deepcopy(self.label[var_name])
                del (self.label[var_name])
            else:
                self.label[line_number] = []
        elif node.kind == clang.cindex.CursorKind.GOTO_STMT:
            if var_name in self.label_name:
                if self.label_name[var_name] in self.label:
                    self.label[self.label_name[var_name]].append(line_number)
                else:
                    self.label[self.label_name[var_name]] = [line_number]
            else:
                temp = self.code[line_number]
                label_name = temp[temp.find("goto") + 4:temp.find(';')].strip()

                if label_name in self.label_name:
                    if self.label_name[label_name] in self.label:
                        self.label[self.label_name[label_name]].append(line_number)
                    else:
                        self.label[self.label_name[label_name]] = [line_number]
                else:
                    if label_name in self.label:
                        self.label[label_name].append(line_number)
                    else:
                        self.label[label_name] = [line_number]
        elif (node.kind == clang.cindex.CursorKind.CALL_EXPR or
              node.kind == clang.cindex.CursorKind.DECL_REF_EXPR) and var_name in self.func_name:
            if self.func_name[var_name] in self.func_usage:
                if line_number not in self.func_usage[self.func_name[var_name]]:
                    self.func_usage[self.func_name[var_name]].append(line_number)
            else:
                self.func_usage[self.func_name[var_name]] = [line_number]

        for child in node.get_children():
            self.visit_node(child)

    def format_source_code(self, program):
        self.code.clear()
        self.func.clear()
        self.func_name.clear()  # Name to line
        self.func_name2.clear()  # Line to name
        self.func_usage.clear()
        self.func_added.clear()
        self.func_call.clear()
        self.glob.clear()
        self.glob_name.clear()
        self.local.clear()
        self.local_name.clear()
        self.def_lines.clear()
        self.assigns.clear()
        self.du_chain_glob.clear()
        self.du_chain_local.clear()
        self.du_chain.clear()
        self.bracket.clear()
        self.label.clear()
        self.label_name.clear()
        self.du_bracket_defs.clear()
        self.du_others.clear()
        self.success = False

        with open(program, 'r') as file:
            data = file.readlines()

        parsed_info = index.parse(program)
        code_info = get_clang_info(parsed_info.cursor)['children']

        text_single = False
        text_double = False
        bracket = []

        for code_chunk in code_info:
            chunk_name = code_chunk['spelling']
            if 'F@' in code_chunk['usr'] and code_chunk['is_definition']:
                current_func = len(self.code)
                self.func[current_func] = None
                self.func_name[chunk_name] = current_func
                self.func_name2[current_func] = chunk_name
                func_dec = get_source_code(code_chunk['start'], code_chunk['children'][-1]['start'], data).replace('\n', ' ').strip().split(',')

                for chunk in func_dec:
                    self.code.append(chunk + ',\n')
                self.code[-1] = self.code[-1][:-2] + '\n'
                for chunk in code_chunk['children'][-1]['children']:
                    if len(chunk['children']) > 0 and chunk['children'][0]['is_definition'] is True:
                        self.code.append(
                            get_source_code(chunk['start'], chunk['end'], data).replace('\n', ' ').strip() + '\n')
                    else:
                        temp = get_source_code(chunk['start'], chunk['end'], data)
                        code_start = 0

                        for i in range(len(temp)):
                            if (temp[i] == "\'" or temp[i] == "\"") and temp[i - 1] == "\\" and temp[i - 2] != "\\":
                                pass
                            elif not text_double and temp[i] == "\'":
                                if text_single:
                                    text_single = False
                                else:
                                    text_single = True
                            elif text_single:
                                pass
                            elif temp[i] == "\"":
                                if text_double:
                                    text_double = False
                                else:
                                    text_double = True
                            elif text_double:
                                pass
                            elif temp[i] == '{':
                                code = temp[code_start:i + 1].replace('\n', ' ').strip()
                                if "{" == code:
                                    bracket.append(False)
                                else:
                                    bracket.append(len(self.code))
                                    self.code.append(code + '\n')
                                code_start = i + 1

                            elif temp[i] == '}':
                                e = bracket.pop()
                                if e:
                                    self.bracket[e] = len(self.code)
                                    self.code.append(temp[code_start:i + 1].replace('\n', ' ').strip() + '\n')
                                code_start = i + 1
                            elif temp[i] == ':':
                                self.code.append(temp[code_start:i + 1].replace('\n', ' ').strip() + '\n')
                                code_start = i + 1
                            elif temp[i] == ';':
                                self.code.append(temp[code_start:i + 1].replace('\n', ' ').strip() + '\n')
                                code_start = i + 1
                self.func[current_func] = len(self.code)
                self.code.append('}\n')
            else:
                source = get_source_code(code_chunk['start'], code_chunk['end'], data).replace('\n', ' ')
                if source[-1] == ';':
                    self.code.append(source + '\n')
        with open(program, 'w') as file:
            file.writelines(self.code)


    def test(self, path):
        try:
            result = subprocess.check_output('. ./setenv && cd ' + path + ' && ./test.sh; echo $?', shell=True,
                                             stderr=subprocess.PIPE)
            if result == b'0\n':
                return True
        except subprocess.CalledProcessError as e:
            pass
        return False

    def generate_debloated_code(self, program):
        for i in reversed(range(len(self.code))):
            if self.code[i][0] == '/' and self.code[i][1] == '/':
                del (self.code[i])

        with open(program, "w") as file:
            file.writelines(self.code)

        while True:
            self.format_source_code(program)
            self.visit_node(index.parse(program).cursor)
            temp = True

            for i in reversed(list(self.bracket.keys())):
                if i + 1 == self.bracket[i]:
                    temp = False
                    if i - 1 in self.label and ";" != self.code[i - 1][-2]:
                        self.code[i - 1] = self.code[i - 1][:-1] + ';\n'
                    if len(self.code) > i + 2 and 'else' in self.code[i + 2]:
                        self.code[i + 2] = self.code[i + 2].replace('else', '')
                    del (self.code[i + 1])
                    del (self.code[i])

            with open(program, "w") as file:
                file.writelines(self.code)

            if temp:
                break

        self.format_source_code(program)
        self.visit_node(index.parse(program).cursor)

        subprocess.check_output("clang -Wall -Wunused-variable -c " + program + " > " + base_path + "unused_vars.txt 2>&1", shell=True)

        with open(base_path + "unused_vars.txt", 'r') as file:
            lines = file.readlines()

        unused_vars = []
        for line in lines:
            match = re.match(r".+:(\d+):\d+: warning: unused variable '(.+)' \[-Wunused-variable\]", line)
            if match:
                line_num, var_name = match.groups()
                unused_vars.append(int(line_num) - 1)

        for i in reversed(range(len(self.code))):
            if i in self.label and self.code[i + 1][0] == '}':
                self.code[i] = self.code[i][:-1] + ';\n'
            elif i in unused_vars:
                del (self.code[i])

        with open(program, "w") as file:
            file.writelines(self.code)


        shutil.copy(program, program + ".debloated.c")

    def is_in_function(self, line_number):
        for start_line in self.func:
            if start_line <= line_number <= self.func[start_line]:
                return start_line
        return False


if __name__ == "__main__":
    # Base setting for program debloating
    clang.cindex.Config.set_library_file('/usr/lib/llvm-8/lib/libclang-8.so.1')
    index = clang.cindex.Index.create()

    if len(sys.argv) > 1:
        project = sys.argv[1]
    else:
        project = "bzip2-1.0.5"
        print("Project name is not specified -- default project Bzip2 is selected.")

    print("Program " + project + " reduction is started.")

    # Base setting from the default path
    base_path = os.path.join(os.getcwd(), project + '/merged/')
    target_file = base_path + project + ".c"
    test_file = base_path + "test.sh"
    shutil.copy(target_file + ".origin.c", target_file)
    remove_comments(target_file)

    # Run Reinforcement Learning-based Delta Debugging to find 1-DU (Definition-Use) chain minimality.
    RLDebloatDU(base_path, target_file, test_file)
