#!/usr/bin/python
# -*- coding: utf-8 -*-

from ansible.module_utils.basic import AnsibleModule
import MySQLdb

DOCUMENTATION = '''
module: count_page
author: Alexandre 
description: Module qui permet d'exécuter une requête SQL 

options: 
  db_name: 
    description: nom de la base de données
    required: yes 
  request: 
    description: requête à exécuter
    required: yes 

'''

EXAMPLES = '''
- name: "SQL" 
  count_page: 
    db_name: "BDD" 
    request: "select * from user;" 
'''

RETURN = '''
results: 
    description: retourne le résultat de la requête 
'''

def main():
    module = AnsibleModule(
        argument_spec=dict(
            db_name=dict(required=True, type='str'),
            request=dict(required=True, type='str'),
        )
    )
    db_name_local = module.params.get('db_name')
    request_local = module.params.get('request')

    db = MySQLdb.connect(db=db_name_local)
    cur = db.cursor()
    cur.execute(request_local)
    results = cur.fetchall()
    db.close()
    module.exit_json(changed=False, results=results)


if __name__ == '__main__':
    main()

