'''
This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
'''
import json
import datetime
import os

etc_dir="/usr/local/etc/nightlytool/";
bin_dir="/usr/local/bin/";

with open(etc_dir+'sandbox_conf.json') as json_data:
    config = json.load(json_data)

products = config['products']
sandboxes = config['sandboxes']

log_folder = "/tmp/logs/" + datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S") + "/";
os.makedirs(log_folder)
print "Working at",log_folder

f = open(log_folder+'report.html', 'w')

f.write("<!DOCTYPE html>\n")
f.write("<html>\n")
f.write("<head>\n")
f.write("	<title>Nightly report</title>\n")
f.write("</head>\n")
f.write("<body>\n")

if (config['update_tools_libs'] == True):
	result = os.system(". /usr/local/etc/nightlytool/nightly_env; update_atlas_tools.sh > "+log_folder+"tools.log ; update_atlas_libs.sh > "+log_folder+"libs.log")
	if (result==0):
		f.write("<p>Update Tools/Libs <b><font color='green'>OK</font></b></p>\n")
	else:
		f.write("<p>Update Tools/Libs <b><font color='red'>ERROR</font></b></p>\n")

for sbx in sandboxes:
	try:
		if (sbx['enabled'] == True):
			try:
				if (sbx['refresh'] == True):
					f.write("<h1>Refresh Sandbox "+sbx['name']+"</h1>\n")
					f.write("<ul>\n")
					result = os.system("svn cleanup /ae/"+sbx['name']);
					if (result==0):
						f.write("<li>Cleanup <b><font color='green'>OK</font></b></li>\n")
					else:
						f.write("<li>Cleanup <b><font color='red'>ERROR</font></b></li>\n")

					result = os.system("bash "+bin_dir+"sbxTool.sh -s "+sbx['name']+" -m refresh -l "+log_folder);
					if (result==0):
						f.write("<li>Refresh <b><font color='green'>OK</font></b></li>\n")

					else:
						f.write("<li>Refresh <b><font color='red'>ERROR</font></b></li>\n")

					f.write("</ul>\n")
			except KeyError:
				pass;
	except KeyError:
		pass;

for sbx in sandboxes:
	if (sbx['enabled'] == True):
		f.write("<h1>Compilation Sandbox "+sbx['name']+"</h1>\n")
		f.write("<ul>\n")

		for product in sbx['products']:
			f.write("<li>"+product['name']+"</li>\n")
			f.write("<ul>")
			try:
				if (product['cortex'] == True):
					result = os.system("bash "+bin_dir+"sbxTool.sh -s "+sbx['name']+" -m cortex -t "+products[product['name']]['cortex']+" -p "+product['name']+" -l "+log_folder);
					if (result==0):
						f.write("<li>Cortex <b><font color='green'>OK</font></b></li>\n")
					else:
						f.write("<li>Cortex <b><font color='red'>ERROR</font></b></li>\n")
					print "Compila host",sbx['name'],product['name'],products[product['name']]['target']
			except KeyError:
				pass;
			try:
				if (product['target'] == True):
					result = os.system("bash "+bin_dir+"sbxTool.sh -s "+sbx['name']+" -m product -t "+products[product['name']]['target']+" -p "+product['name']+" -l "+log_folder);
					if (result==0):
						f.write("<li>Target <b><font color='green'>OK</font></b></li>\n")
					else:
						f.write("<li>Target <b><font color='red'>ERROR</font></b></li>\n")
					print "Compila host",sbx['name'],product['name'],products[product['name']]['target']
			except KeyError:
				pass;
			try:
				if (product['host'] == True):
					result = os.system("bash "+bin_dir+"sbxTool.sh -s "+sbx['name']+" -m host -t "+products[product['name']]['target']+" -p "+product['name']+" -l "+log_folder);
					if (result==0):
						f.write("<li>Host <b><font color='green'>OK</font></b></li>\n")
					else:
						f.write("<li>Host <b><font color='red'>ERROR</font></b></li>\n")
					print "Compila host",sbx['name'],product['name'],products[product['name']]['target']
			except KeyError:
				pass;
			try:
				if (product['host_cmake'] == True):
					result = os.system("bash "+bin_dir+"sbxTool.sh -s "+sbx['name']+" -m host_cmake -t "+products[product['name']]['target']+" -p "+product['name']+" -l "+log_folder);
					if (result==0):
						f.write("<li>Host cmake <b><font color='green'>OK</font></b></li>\n")
					else:
						f.write("<li>Host cmake <b><font color='red'>ERROR</font></b></li>\n")
					print "Compila host",sbx['name'],product['name'],products[product['name']]['target']
			except KeyError:
				pass;
			f.write("</ul>")
			f.write("</li>")
		f.write("</ul>")

f.write("</body>\n")
f.write("</html>\n")
f.close()

os.system("export DISPLAY=:0 && sensible-browser "+log_folder+"report.html &")
