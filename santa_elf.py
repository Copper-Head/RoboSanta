import os

def load_files(path, extension=".lp"):
	
	file_list = []
	
	for root, dirs, files in os.walk(path):
		for file_ in files:
			if file_.endswith(extension):
				# use absolute or relative file name in output?
				#file_list.append(os.path.abspath(file_))
				file_list.append(os.path.join(root, file_))

	return file_list				
				
def parse_modules(files):
	
	# dict will hold all the files for a particular module
	modules = {}
		
	for file_ in files:
		module_name = file_.split("_")[0]
		if module_name not in modules:
			modules[module_name] = []
		
		modules[module_name].append(file_)
			
	return modules
		

def choose_module(modules):

	chosen_files = []
	
	for key, val in modules.iteritems():
		print("choose module number:")
		for i in zip(range(1,len(val)+1),val):
			print i
		selection = list(raw_input().split(" "))
		chosen_files += [val[int(i)-1] for i in selection]
		print

	return chosen_files
	
	
def create_script(files, file_name="robosanta.sh"):

	with open(file_name, "w") as f:
		f.write("#!bin/bash\n\n")
		f.write("INSTANCE=$1\n")
		f.write("clingo " + " ".join(files) + " $INSTANCE")

create_script(choose_module(parse_modules(load_files("."))))