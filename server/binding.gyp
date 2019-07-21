{
  'targets': [
    {
      "target_name": "addon",
      "include_dirs": ['irext/include'], 
      'sources': [ 'air.cc', '<!@(ls -1 irext/src/*.c)']
    }
  ]
}