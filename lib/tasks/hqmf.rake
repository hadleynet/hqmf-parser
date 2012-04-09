namespace :hqmf do

  desc 'Open a console for interacting with parsed HQMF'
  task :console do
    
    def load_hqmf(id)
      HQMF::Document.new(File.expand_path(File.join(".","test","fixtures","NQF_Retooled_Measure_#{id}.xml")))
    end
    
    Pry.start
  end

  desc 'Parse all xml files and save them to /tmp'
  task :parse_all do
    require 'fileutils'
    FileUtils.mkdir_p File.join(".","tmp",'json')
    Dir.glob(File.join(".","test",'fixtures','all_xml','*.xml')) do |measure_def|
      puts "processing #{measure_def}..."
      doc = HQMF::Document.new(File.expand_path(measure_def))
      nqf_id = doc.to_json[:metadata]['NQF_ID_NUMBER'][:value]
      File.open(File.join(".","tmp",'json',"#{nqf_id}.json"), 'w') {|f| f.write(doc.to_json) }
    end
    
  end
  
end