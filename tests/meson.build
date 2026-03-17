if build_gtk3_targets
  foreach test_data : [
    ['test0.gtkaml', 'test0'],
    ['test4.gtkon', 'test4'],
    ['test5.gtkon', 'test5'],
    ['test7.gtkon', 'test7'],
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
        '-o',
        '@OUTPUT@',
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
