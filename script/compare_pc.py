import sys
import re
class ComparePC:
    def __init__(self, input_data0, input_data1):
        self.input_data0 = open(input_data0, "r")
        self.input_data1 = open(input_data1, "r")
        self.pattern = r"(^[0-9a-fA-F]+)[ ]+([0-9a-fA-F]+)[ ]+([0-9a-fA-F]+)[ ]+([0-9a-fA-F]+)[ ]"

    def compare(self):
        while 1:
            access_time0 = 0
            access_time1 = 0
            instruction0 = 0
            instruction1 = 0
            instruction_addr0 = 0
            instruction_addr1 = 0
            valid0 = 0
            valid1 = 0
            while 1:
                line0 = self.input_data0.readline()
                if not line0:
                    break
                matches0 = re.findall(self.pattern, line0, re.DOTALL)
                if len(matches0) > 0:
                    if matches0[0][3] == "1":
                        access_time0 = matches0[0][0]
                        instruction0 = matches0[0][1]
                        instruction_addr0 = matches0[0][2]
                        break
            while 1:
                line1 = self.input_data1.readline()
                if not line1:
                    break
                matches1 = re.findall(self.pattern, line1, re.DOTALL)
                if len(matches1) > 0:
                    if matches1[0][3] == "1":
                        access_time1 = matches1[0][0]
                        instruction1 = matches1[0][1]
                        instruction_addr1 = matches1[0][2]
                        break
            if instruction0 != instruction1 or instruction_addr0 != instruction_addr1:
                print("Instruction mismatch: {}-{}-{}, {}-{}-{}".format(access_time0, instruction0, instruction_addr0, access_time1, instruction1, instruction_addr1))
                break

if __name__ == "__main__":
    input_data0 = sys.argv[1]
    input_data1 = sys.argv[2]
    compare_pc = ComparePC(input_data0, input_data1)
    compare_pc.compare()