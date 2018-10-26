#!/usr/bin/env python3
import json
import sys

def process(filename):
    f = open(filename, 'r')
    data = f.readline()
    js = json.loads(data)
    args = js['arguments']
    res = js['expected']
    arg_types = []
    res_types = []
    for i in args:
        typename = type(i).__name__
        if typename == 'list':
            arg_types.append('list({})'.format(type(i[0]).__name__))
        elif typename == 'dict':
            k = type(list(i.items())[0][0]).__name__
            v = type(list(i.items())[0][1]).__name__
            arg_types.append('dict({},{})'.format(k,v))
        else:
            arg_types.append(typename)
    for i in res:
        typename = type(i).__name__
        if typename == 'list':
            res_types.append('list({})'.format(type(i[0]).__name__))
        elif typename == 'dict':
            k = type(list(i.items())[0][0]).__name__
            v = type(list(i.items())[0][1]).__name__
            res_types.append('dict({},{})'.format(k,v))
        else:
            res_types.append(typename)
    return (arg_types, res_types)

type_correspondence = {'int' : 'Int', 'str' : 'String', 'float' : 'Double'}

def generate_hask(types):
    ty = []
    for t in types:
        if t[:4] == 'list':
            ty.append('[{}]'.format(type_correspondence[t[5:-1]]))
        elif t[:4] == 'dict':
            x = t[5:-1].split(',')
            ty.append('Map {} {}'.format(type_correspondence[x[0]], type_correspondence[x[1]]))
        else:
            ty.append(type_correspondence[t])
    if len(ty) > 1:
        print('(' + ', '.join(ty) + ')')
    else:
        print('[' + ', '.join(ty) + ']')
    # print(ty)

if __name__ == '__main__':
    arg_types, res_types = process(sys.argv[1])
    generate_hask(arg_types)
    generate_hask(res_types)