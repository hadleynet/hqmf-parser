require 'pathname'
require 'fileutils'
require 'json'

namespace :hqmf do

  desc 'Open a console for interacting with parsed HQMF'
  task :console do
    
    def load_hqmf(id)
      HQMF1::Document.new(File.expand_path(File.join(".","test","fixtures","NQF_Retooled_Measure_#{id}.xml")))
    end
    
    Pry.start
  end

  desc 'Parse all xml files to JSON and save them to /tmp'
  task :parse_all, [:path, :version] do |t, args|
    
    raise "You must specify the HQMF XML file path to convert" unless args.path
    
    FileUtils.mkdir_p File.join(".","tmp",'json')
    path = File.expand_path(args.path)
    version = args.version || HQMF::Parser::HQMF_VERSION_1
    
    Dir.glob(File.join(path,'*.xml')) do |measure_def|
      puts "processing #{measure_def}..."
      doc = HQMF::Parser.parse(File.open(measure_def).read, version)
      filename = Pathname.new(measure_def).basename
      
      File.open(File.join(".","tmp",'json',"#{filename}.json"), 'w') {|f| f.write(doc.to_json.to_json) }
    end
    
  end

  desc 'Parse specified xml file to JSON and save it to /tmp'
  task :parse, [:file,:version] do |t, args|
    FileUtils.mkdir_p File.join(".","tmp",'json')
    
    raise "You must specify the HQMF XML file to convert" unless args.file
    
    version = args.version || HQMF::Parser::HQMF_VERSION_1
    file = File.expand_path(args.file)
    filename = Pathname.new(file).basename
    
    doc = HQMF::Parser.parse(File.open(file).read, version)

    File.open(File.join(".","tmp",'json',"#{filename}.json"), 'w') {|f| f.write(doc.to_json.to_json) }
    
  end
  

  
end