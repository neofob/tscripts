#!/usr/bin/env python3
# pgpt_query.py --config instruct.yml --input transcript.txt
# TODO: --output transcript-summary.md
import argparse
import os
import pprint
import yaml

from pgpt_python.client import PrivateGPTApi


pp = pprint.PrettyPrinter(indent=2)

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--config', dest='config', action='store', help='Config file', required=True)
parser.add_argument('-i', '--input', dest='input', action='store', help='Input content', required=True)
#parser.add_argument('-output', '--input', dest='input', action='store', help='Input content', required=True)

config_file = parser.parse_args().config
input_file = parser.parse_args().input

with open(config_file, "r") as file:
    my_config = yaml.safe_load(file)

base_url = f"http://{my_config['instruct']['url']}:{int(my_config['instruct']['port'])}"

#pp.pprint(base_url)

#os._exit(0)

client = PrivateGPTApi(base_url=base_url, timeout=my_config['instruct']['timeout'])
#print(client.health.health())

# form messages
messages = []
messages.append({"role": "system", "content": my_config['instruct']['system']})

final_user_text = my_config['instruct']['instruct']
content = open(input_file, 'r').read()
final_user_text = final_user_text + os.linesep + \
"```" + os.linesep + \
content + \
os.linesep + \
"```"

#print(final_user_text)

messages.append({"role": "user", "content": final_user_text })
# blocking call
chat_result = client.contextual_completions.chat_completion(messages=messages, timeout=my_config['instruct']['timeout'])
print(chat_result.choices[0].message.content)
