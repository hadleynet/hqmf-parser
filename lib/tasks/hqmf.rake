namespace :hqmf do

  desc 'Open a console for interacting with parsed HQMF'
  task :console do
    
    def load_hqmf(id)
      HQMF::Document.new(File.expand_path(File.join(".","test","fixtures","NQF_Retooled_Measure_#{id}.xml")))
    end
    
    Pry.start
  end
  
end