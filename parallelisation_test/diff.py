import filecmp
import glob
import sys

path1 = sys.argv[1]
path2 = sys.argv[2]

if (path1[-1] != '/'):
    path1 = path1 + '/'

if (path2[-1] != '/'):
    path2 = path2 + '/'


binary_files_async = glob.glob(path1 + "*.bin")
binary_files_noasync = glob.glob(path2 + "*.bin")

# if (len(binary_files_async) != len(binary_files_noasync)):
#   print ("Amount of binary files not equal")

binary_files_async.sort()
binary_files_noasync.sort()

res = "Success"
i = 0
j = 0
while (i < len(binary_files_async) and j < len(binary_files_noasync)):
    p1 = binary_files_async[i]
    p2 = binary_files_noasync[j]
    if (p1[p1.rfind("/"):] < p2[p2.rfind("/"):]):
        i += 1
        continue
    elif (p1[p1.rfind("/"):] > p2[p2.rfind("/"):]):
        j += 1
        continue
    if (not filecmp.cmp(binary_files_async[i], binary_files_noasync[j])):
        print (binary_files_async[i] + " and " + binary_files_noasync + " are not equal")
        res = "Fail"
        break
    else:
        print (p1[1+p1.rfind("/"):] + " passed")
        i += 1
        j += 1
          
          
print("Done: " + res)
