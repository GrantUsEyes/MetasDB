import sys #system module
import getopt #getopt module allowing me to do command line options
import re #Python regex module (for splitting).

def usage(): #Shows usage for command line options
    print('COMMAND LINE OPTIONS FOR THIS PROGRAM:\n',
            '-i specifies the name of the input file.\n',
            '-o specifies the name of the output file.(Must be a sql file)\n')

inName = '' #Name of the file being dumped.
outName = '' #Name of the .sql file being output.
inserts = '' #String containing all insert statements.
lineNum = 1 #Allows for tracking of the line numbers, mainly for setting variables in the .sql file. NOT ZERO BASED!!!
varList = [] #List of variables in the file.


try: #Grabs relevant input and outputs a formatted sql file tailored to the simulation data. 
    opts, args = getopt.getopt(sys.argv[1:], "i:o:")
    for (opt, arg) in opts:
        if opt == '-i':
            inName = arg
        if opt == '-o':
            if '.sql' in arg:
                outName = arg
            else:
               print("\nSorry please try again with a .sql file!\n")
               usage()
               exit()

    
    fileIn = open(inName, 'r')

    print("\nProcessing your .sql file, the .csv is large so it may take some time")
    for line in fileIn:
        if lineNum % 10000 == 0:
            print('working on it...\n')
        if '\n' in line:
            line = line[:-1]
            if lineNum == 1:
                varList = re.split(',', line)
            else:
                inserts = inserts + "(" + line + "),"
            lineNum = lineNum + 1
    inserts = inserts[:-1] + ";\n"
    fileIn.close()

    outFile = open(outName, 'w')
    outFile.write("USE zwright;\n" + "DROP TABLE IF EXISTS MetasDB;\n\n" + "CREATE TABLE MetasDB (\n")

    for var in varList:
        if var != "TRUE" or var != "FALSE":
            outFile.write(var + " int(5),\n")
        else:
            outFile.write(var + " varchar(5),\n")
    outFile.write("PRIMARY KEY(run_ID, steps)\n);\n" + "LOCK TABLES MetasDB WRITE;\n" + "INSERT INTO MetasDB VALUES " + inserts)
    outFile.close()
    print('Finished! Your .sql file can now be queried.')


    



    
except getopt.GetoptError as err: #Handles command line exceptions
    print('COMMAND LINE OPTION NOT RECOGNIZED, PRINTING ERROR INFORMATION:')
    sys.stdout = sys.stderr
    print('\n', str(err))
    usage()
    sys.exit()
