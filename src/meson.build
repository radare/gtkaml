gtkamlc_sources = files(
  'GtkamlAttribute.vala',
  'GtkamlClassDefinition.vala',
  'GtkamlCodeContext.vala',
  'GtkamlCodeGenerator.vala',
  'GtkamlCompiler.vala',
  'GtkamlComplexAttribute.vala',
  'GtkamlImplicitsResolver.vala',
  'GtkamlImplicitsStore.vala',
  'GtkamlMethod.vala',
  'GtkamlMethodMatcher.vala',
  'GtkamlParser.vala',
  'GtkamlReferenceClassDefinition.vala',
  'GtkamlRootClassDefinition.vala',
  'GtkamlSAXParser.vala',
  'GtkamlSimpleAttribute.vala',
  'GtkamlState.vala',
  'GtkamlStateStack.vala',
  'GtkamlXmlAttribute.vala',
  'GtkamlXmlNamespace.vala',
  'GtkonParser.vala',
)

c_compiler = meson.get_compiler('c')
valaccodegen_lib = c_compiler.find_library(
  'valaccodegen',
  dirs: [vala_codegen_libdir],
  required: true,
)

valaccodegen_dep = declare_dependency(
  dependencies: valaccodegen_lib,
  include_directories: vapi_inc,
)

gtkamlc = executable(
  'gtkamlc',
  [
    config_vapi,
    valaccodegen_vapi,
    gtkamlc_sources,
    'GtkamlSAXParser_start_parsing.c',
  ],
  dependencies: [
    valaccodegen_dep,
  ] + common_deps,
  include_directories: [
    root_inc,
    vapi_inc,
  ],
  vala_args: [
    '--vapidir=' + vala_internal_vapi_dir,
  ],
  build_rpath: vala_codegen_libdir,
  install_rpath: vala_codegen_libdir,
  install: true,
)

install_symlink(
  'gtkaml',
  pointing_to: 'gtkamlc',
  install_dir: get_option('bindir'),
)
