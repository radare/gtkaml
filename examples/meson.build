clutter_gtk_dep = dependency('clutter-gtk-1.0', required: false)
clutter_dep = dependency('clutter-1.0', required: false)
mx_dep = dependency('mx-1.0', required: false)
stk_dep = dependency('stk-1.0', required: false)

if build_gtk3_targets
  subdir('SimpleViewer2')
  subdir('gtkaml')
  subdir('gtkon')
endif

if build_gtk3_targets and clutter_gtk_dep.found() and clutter_dep.found() and mx_dep.found()
  subdir('clutter')
endif

if build_gtk3_targets and stk_dep.found()
  subdir('blitzen')
endif
