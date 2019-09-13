# frozen_string_literal: true

require 'tk'

class Cartridge
  attr_reader :header

  CartridgeHeader = Struct.new(
    :entry_point,
    :nintendo_logo,
    :game_title,
    :game_code,
    :maker_code,
    :fixed_value,
    :main_unit_code,
    :device_type,
    :reserved_area_1,
    :software_version,
    :complement_check,
    :reserved_area_2
  )

  def initialize(path)
    @path = path
    @header = parse_header
  end

  def parse_header
    File.open(@path, 'rb') do |file|
      # decode binary data
      data = file.read(192).unpack('H8 H312 A12 A4 A2 H2 H2 H2 H14 H2 H2 H4')
      CartridgeHeader.new(*data)
    end
  end
end

class GUI
  def initialize(parent)
    @file_path = ''
    @root = parent

    menu_bar
    set_frames
    set_binds

    @label1 = TkLabel.new(@frame1, text: 'Game Title:', width: 10).pack(anchor: :e)
    @text1 = TkText.new(@frame2, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)

    @label2 = TkLabel.new(@frame1, text: 'Game Code:', width: 10).pack(anchor: :e)
    @text2 = TkText.new(@frame2, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)

    @label3 = TkLabel.new(@frame1, text: 'Maker Code:', width: 10).pack(anchor: :e)
    @text3 = TkText.new(@frame2, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)

    @label4 = TkLabel.new(@frame1, text: 'Main Unit:', width: 10).pack(anchor: :e)
    @text4 = TkText.new(@frame2, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)

    @label5 = TkLabel.new(@frame3, text: 'Device Type:', width: 18).pack(anchor: :e)
    @text5 = TkText.new(@frame4, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)

    @label6 = TkLabel.new(@frame3, text: 'Software Version:', width: 18).pack(anchor: :e)
    @text6 = TkText.new(@frame4, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)

    @label7 = TkLabel.new(@frame3, text: 'Complement Check:', width: 18).pack(anchor: :e)
    @text7 = TkText.new(@frame4, state: :disabled, width: 14, height: 1, wrap: :none).pack(anchor: :w)
  end

  def menu_bar
    menu_spec = [
      [['File', 0],
       { label: 'Open', command: proc { open_file }, accel: 'Ctrl+O' },
       '-',
       { label: 'Quit', command: proc { exit }, accel: 'Ctrl+Q' }],
      [['Help', 0],
       { label: 'About', command: proc { about_box }, accel: '<F1>' }]
    ]
    TkMenubar.new(@root, menu_spec, tearoff: false).pack(fill: :x, side: :top)
  end

  def set_binds
    @root.bind('Control-o', proc {  open_file })
    @root.bind('Control-q', proc {  exit })
    @root.bind('Any-F1', proc { about_box })
  end

  def set_frames
    @main_frame = TkFrame.new(@root, borderwidth: 10)
                         .pack(side: :top, fill: :both, expand: true)

    @frame1 = TkFrame.new(@main_frame)
                     .pack(side: :left, fill: :both, expand: true)
    @frame2 = TkFrame.new(@main_frame)
                     .pack(side: :left, fill: :both, expand: true)
    @frame3 = TkFrame.new(@main_frame)
                     .pack(side: :left, fill: :both, expand: true)
    @frame4 = TkFrame.new(@main_frame)
                     .pack(side: :left, fill: :both, expand: true)
  end

  def open_file
    file_types = [['GBA ROMs', '*.gba'], ['All files', '*']]
    @file_path = Tk.getOpenFile(filetypes: file_types, parent: @root)

    populate_content unless @file_path.empty?
  end

  def populate_content
    cart = Cartridge.new(@file_path)

    @text1[:state] = :normal
    @text1.delete(1.0, :end)
    @text1.insert(1.0, cart.header.game_title)
    @text1[:state] = :disabled

    @text2[:state] = :normal
    @text2.delete(1.0, :end)
    @text2.insert(1.0, cart.header.game_code)
    @text2[:state] = :disabled

    @text3[:state] = :normal
    @text3.delete(1.0, :end)
    @text3.insert(1.0, cart.header.maker_code)
    @text3[:state] = :disabled

    @text4[:state] = :normal
    @text4.delete(1.0, :end)
    @text4.insert(1.0, cart.header.main_unit_code)
    @text4[:state] = :disabled

    @text5[:state] = :normal
    @text5.delete(1.0, :end)
    @text5.insert(1.0, cart.header.device_type)
    @text5[:state] = :disabled

    @text6[:state] = :normal
    @text6.delete(1.0, :end)
    @text6.insert(1.0, cart.header.software_version)
    @text6[:state] = :disabled

    @text7[:state] = :normal
    @text7.delete(1.0, :end)
    @text7.insert(1.0, cart.header.complement_check)
    @text7[:state] = :disabled
  end

  def about_box
    Tk.messageBox(parent: @root, detail: "R1\nhttps://github.com/mdpcardoso/AGBHeaderTool", icon: :info, type: :ok, title: 'About',
                  message: "AGB Header Tool\n" \
                           "\nRuby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]\n" \
                           "tcltklib #{TclTkLib::RELEASE_DATE}\ntk #{Tk::RELEASE_DATE}")
  end
end

root = TkRoot.new(title: 'AGB Header Tool', minsize: [375, 150])
GUI.new(root)

Tk.mainloop
