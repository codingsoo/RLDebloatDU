# ICSE Poster Submission

This README file provides instructions on setting up the environment, installing dependencies, and running our project.

## Environment

This project was developed and tested on Ubuntu 20.04.

## Dependencies

To run this project, you need to have the following software installed:

- Python 3
- LLVM
- Clang
- Clang library

### Installing Dependencies

Run the following commands to install the required software:

```
sudo apt-get update
sudo apt-get install python3-pip clang libclang llvm
pip install clang
```

After installing Clang, specify the libclang's path in the main.py file.

```
# Line 817, default path is '/usr/lib/llvm-8/lib/libclang-8.so.1'
clang.cindex.Config.set_library_file('/usr/lib/llvm-8/lib/libclang-8.so.1') 
```

## Running the Project

The `benchmark` directory contains ten Linux kernel programs used in the submitted paper. To run the project with one of these programs, use the following commands:

```
cd benchmark
python3 main.py [program name]
```

Replace `[program_name]` with the desired program name.

### Example

To run the project with Tar-1.14, use the following commands:

```
cd benchmark
python3 main.py tar-1.14
```

The output file will be stored in the program's directory.
