" Vim syntax file
" Maintainers:  pancake <pancake@nopcode.org>
" Language:	GtkAML
" Filenames:	*.gtkaml

"Comments
"syn match   gtkamlTag 		"CDATA"
syn match   gtkamlTag 		"<"
syn match   gtkamlTag 		">"
syn keyword gtkamlTodo		contained TODO FIXME XXX NOTE
syn region  gtkamlComment	start="<!--"  end="-->" contains=gtkamlTodo

"Strings
syn region  gtkamlString	start="\"" end="\"" skip="\\\""
syn region  gtkamlString	start="'" end="'" skip="\\'"

"Numbers
syn match   gtkamlNumber	"\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
syn match   gtkamlNumber	"\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match   gtkamlNumber	"\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match   gtkamlNumber	"\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"
syn match   gtkamlTag 		"<[^[\s|:]*]"
syn match   gtkamlTag 		"\/>"

"Keywords
syn keyword xml DOCTYPE
syn keyword gtkamlKeywords name namespace implements public private existing standalone construct preconstruct
syn keyword gtk2Keywords AboutDialog AccelGroup AccelGroupEntry AccelLabel AccelMap AccelMapClass Accessible Action ActionGroup Adjustment Alignment Arg Arrow AspectFrame Assistant Bin BindingArg BindingEntry BindingSet BindingSignal Border Box BoxChild Builder Button ButtonBox Calendar CellRendererAccel CellRendererCombo CellRendererPixbuf CellRendererProgress CellRendererSpin CellRendererSpinner CellRendererText CellRendererToggle CellView CheckButton CheckMenuItem Clipboard ColorButton ColorSelection ColorSelectionDialog ComboBox ComboBoxEntry Container Curve Dialog DrawingArea Entry EntryBuffer EntryCompletion EventBox Expander FileChooserButton FileChooserDialog FileChooserWidget FileFilter FileFilterInfo Fixed FixedChild FontButton FontSelection FontSelectionDialog Frame GammaCurve HBox HButtonBox HPaned HRuler HSV HScale HScrollbar HSeparator HandleBox IMContext IMContextSimple IMMulticontext IconFactory IconInfo IconSet IconSource IconTheme IconView Image ImageAnimationData ImageGIconData ImageIconNameData ImageIconSetData ImageImageData ImageMenuItem ImagePixbufData ImagePixmapData ImageStockData InfoBar InputDialog Invisible Item Label LabelSelectionInfo Layout LinkButton ListStore Menu MenuBar MenuItem MenuShell MenuToolButton MessageDialog Misc MountOperation Notebook NotebookPage Object OffscreenWindow PageRange PageSetup Paned PaperSize Plug PrintContext PrintOperation PrintSettings ProgressBar RadioAction RadioButton RadioMenuItem RadioToolButton Range RangeLayout RangeStepTimer RcContext RcProperty RcStyle RecentAction RecentChooserDialog RecentChooserMenu RecentChooserWidget RecentFilter RecentFilterInfo RecentInfo RecentManager Ruler RulerMetric Scale ScaleButton Scrollbar ScrolledWindow SelectionData Separator SeparatorMenuItem SeparatorToolItem Settings SettingsPropertyValue SettingsValue SizeGroup Socket SpinButton Spinner StatusIcon Statusbar Style Table TableChild TableRowCol TargetList TargetPair TearoffMenuItem TextAppearance TextAttributes TextBTree TextBuffer TextChildAnchor TextLogAttrCache TextMark TextPendingScroll TextTag TextTagTable TextView TextWindow ThemeEngine ToggleAction ToggleButton ToggleToolButton ToolButton ToolItem ToolItemGroup ToolPalette Toolbar Tooltip TreeModelFilter TreeModelSort TreePath TreeRowReference TreeSelection TreeStore TreeView TreeViewColumn UIManager VBox VButtonBox VPaned VRuler VScale VScrollbar VSeparator Viewport VolumeButton Widget WidgetAuxInfo WidgetShapeInfo Window WindowGeometryInfo WindowGroup

"GtkCode uses Vala syntax for inlined cdata code
syntax include @vala syntax/vala.vim 
syntax region valaCode  start=+<!\[CDATA\[+ keepend end=+]]>+  contains=xmlCdataStart,xmlCdataEnd,@xmlCdataHook,@vala keepend extend
syntax region valaCode  start=+{+ keepend end=+\}+  contains=@vala
syn match    xmlCdataStart +<!\[CDATA\[+  contained contains=xmlCdataCdata
syn keyword  xmlCdataCdata CDATA          contained
syn match    xmlCdataEnd   +]]>+          contained

"Format
hi def link xmlCdataStart	Type
hi def link xmlCdataCdata	Keyword
hi def link xmlCdataEnd		Type

hi def link gtkamlTodo		Todo
hi def link gtkamlComment	Comment
hi def link gtkamlString	String
hi def link gtkamlNumber	Number
hi def link gtkamlKeywords	Type
hi def link gtkamlTag		Type
hi def link gtk2Keywords	Keyword

