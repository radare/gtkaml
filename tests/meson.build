if build_gtk3_targets
  foreach test_data : [
    ['test0.gtkaml', 'test0.vala'],
    ['test4.gtkon', 'test4.vala'],
    ['test5.gtkon', 'test5.vala'],
    ['test7.gtkon', 'test7.vala'],
  ]
    custom_target(
      'gtk3-smoke-' + test_data[1],
      input: test_data[0],
      output: test_data[1],
      command: [
        gtkamlc,
        '--pkg',
        'gtk+-3.0',
      ] + gtkamlc_markup_args + [
        '-V',
        '@INPUT@',
      ],
      build_by_default: true,
    )
  endforeach
endif

if build_gtk4_targets
  subdir('gtk4')
endif

if build_adwaita_targets
  subdir('adwaita')
endif
