" Vim syntax file
" Maintainers:  pancake <pancake@nopcode.org>
" Language:	GtkON
" Filenames:	*.gtkon

"Comments
syn keyword gtkonTodo		contained TODO FIXME XXX NOTE
syn region  gtkonComment	start="/\*"  end="\*/" contains=gtkonTodo
syn match   gtkonComment	"//.*$" contains=gtkonTodo
syn match   gtkonComment	"#.*$" contains=gtkonTodo

"Strings
syn region  gtkonString		start="\""	end="\"" skip="\\\""
syn region  gtkonString		start="'"	end="'" skip="\\'"

"Numbers
syn match   gtkNumber		"\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
syn match   gtkNumber		"\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match   gtkNumber		"\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match   gtkNumber		"\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"

"Keywords
syn	keyword	gtkamlKeywords name namespace implements public private existing standalone construct preconstruct
syn keyword gtk2Keywords AboutDialog AccelGroup AccelGroupEntry AccelLabel AccelMap AccelMapClass Accessible Action ActionGroup Adjustment Alignment Arg Arrow AspectFrame Assistant Bin BindingArg BindingEntry BindingSet BindingSignal Border Box BoxChild Builder Button ButtonBox Calendar CellRendererAccel CellRendererCombo CellRendererPixbuf CellRendererProgress CellRendererSpin CellRendererSpinner CellRendererText CellRendererToggle CellView CheckButton CheckMenuItem Clipboard ColorButton ColorSelection ColorSelectionDialog ComboBox ComboBoxEntry Container Curve Dialog DrawingArea Entry EntryBuffer EntryCompletion EventBox Expander FileChooserButton FileChooserDialog FileChooserWidget FileFilter FileFilterInfo Fixed FixedChild FontButton FontSelection FontSelectionDialog Frame GammaCurve HBox HButtonBox HPaned HRuler HSV HScale HScrollbar HSeparator HandleBox IMContext IMContextSimple IMMulticontext IconFactory IconInfo IconSet IconSource IconTheme IconView Image ImageAnimationData ImageGIconData ImageIconNameData ImageIconSetData ImageImageData ImageMenuItem ImagePixbufData ImagePixmapData ImageStockData InfoBar InputDialog Invisible Item Label LabelSelectionInfo Layout LinkButton ListStore Menu MenuBar MenuItem MenuShell MenuToolButton MessageDialog Misc MountOperation Notebook NotebookPage Object OffscreenWindow PageRange PageSetup Paned PaperSize Plug PrintContext PrintOperation PrintSettings ProgressBar RadioAction RadioButton RadioMenuItem RadioToolButton Range RangeLayout RangeStepTimer RcContext RcProperty RcStyle RecentAction RecentChooserDialog RecentChooserMenu RecentChooserWidget RecentFilter RecentFilterInfo RecentInfo RecentManager Ruler RulerMetric Scale ScaleButton Scrollbar ScrolledWindow SelectionData Separator SeparatorMenuItem SeparatorToolItem Settings SettingsPropertyValue SettingsValue SizeGroup Socket SpinButton Spinner StatusIcon Statusbar Style Table TableChild TableRowCol TargetList TargetPair TearoffMenuItem TextAppearance TextAttributes TextBTree TextBuffer TextChildAnchor TextLogAttrCache TextMark TextPendingScroll TextTag TextTagTable TextView TextWindow ThemeEngine ToggleAction ToggleButton ToggleToolButton ToolButton ToolItem ToolItemGroup ToolPalette Toolbar Tooltip TreeModelFilter TreeModelSort TreePath TreeRowReference TreeSelection TreeStore TreeView TreeViewColumn UIManager VBox VButtonBox VPaned VRuler VScale VScrollbar VSeparator Viewport VolumeButton Widget WidgetAuxInfo WidgetShapeInfo Window WindowGeometryInfo WindowGroup

"GtkCode uses C# syntax
syntax include @vala syntax/vala.vim 
syntax region valaCode  start=+-{+ keepend end=+}-+  contains=@vala

"Format
hi def link gtkonTodo		Todo
hi def link gtkonComment	Comment
hi def link gtkonString		String
hi def link gtkNumber		Number
hi def link gtkamlKeywords	Type
hi def link gtk2Keywords	Keyword
