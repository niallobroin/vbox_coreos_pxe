#!/usr/bin/env python

import subprocess
from bottle import route, run, template, static_file


#Get the vboxnet0 ipaddr
intf = 'vboxnet0'
intf = 'virbr0'
intf_ip = subprocess.check_output(['ip', 'address', 'show', 'dev', intf]).split()
intf_ip = intf_ip[intf_ip.index('inet') + 1].split('/')[0]

#TODO Error checking
HOSTURL = "http://%s:4443" % (intf_ip)

BASEURL = "http://127.0.0.1:4443"

GUESTIP = '192.168.56.102'

@route('/images/coreos/<filename>')
def index(filename):
    print 'images/coreos', filename
    return static_file(filename, root='images/coreos')

MAP = {
#       'xx:xx': (pxe, ks/cloud-config') 
        'c0': ('coreos.pxe', 'basic-cloud-config.yml'),
        'c1': ('coreos_local.pxe', 'basic-cloud-config.yml'),
        'c2': ('coreos.pxe', 'full-cloud-config.yml'),
        'c3': ('coreos_local.pxe', 'full-cloud-config.yml'),
        }



@route('/<typ>/<mac>/')
def index(typ, mac):
    if typ not in ['ipxe', 'kickstart', 'cloud-config']:
        raise Exception

    if typ == 'ipxe':
        tplname = MAP[mac[-5:-3]][0]
        data = {'host_url': HOSTURL, 'base_url': BASEURL}

    elif typ == 'kickstart':
        tplname = MAP[mac[-5:-3]][1]
        data = {'host_url': HOSTURL, 'base_url': BASEURL}

    elif typ == 'cloud-config':

        num = mac[-3:]
        tplname = MAP[mac[-5:-3]][1]
        key_filename = 'ssh-keys/id_rsa_coreos.pub'
        data = {'sshkey': file(key_filename).read(),
                'hostname': '%s_%s' % (mac[-5:-3], num),
                'private_ipv4': GUESTIP,
                'public_ipv4': GUESTIP,}

    else:
        raise Exception


    print "Recieved %s and mac %s  Serving %s" % (typ, mac, tplname)

    tpl = file('templates/' + tplname).read()

    return template(tpl, **data)



run(host='0.0.0.0', port=4443)
