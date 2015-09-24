require 'yaml'
require 'erubis'
require 'xmlsimple'

@verbose=false
if ARGV.size >= 2
if ARGV[1] == "verbose"
@verbose=true
end
end
#interface = YAML.load_file(ARGV[0]+'.yml')
xs = XmlSimple.new({ 'ForceArray' => true, 'KeepRoot' => true})


#File.open(ARGV[0]+'.xml','r') { |source_file|
#  contents = source_file.read
#  contents.gsub!(/[\x02]/,"\x22")
#  contents.gsub!(/[\x06]/,"\x26")
#  contents.gsub!(/[\x07]/,"\x27")
#  contents.gsub!(/[\x1C]/,"\x3C")
#  contents.gsub!(/[\x1E]/,"\x3E")
#  File.open(ARGV[0]+'_mod.xml', "w") { |f| f.write(contents) }
#}
#xmlfile = File.open(ARGV[0]+'_mod.xml','r')

alwaysCall = Hash.new
stage = Hash.new
xmlfile = File.open(ARGV[0]+'.xml','r')
system = xs.xml_in(xmlfile)
#p system
system=system["SYSTEM"]
system.each do |sysfun|
  sysfun["SYS_FUN"].each do |s|
    alwaysCall[s["NAME"]]=1
    if !s["GATE"].nil?
    s["GATE"].each do |g|
      if !g["CHECK"].nil?
      g["CHECK"].each do |n|
      stage[n["NAME"]] = Hash.new
      end
      end
    end
    end
  end
end
system.each do |sysfun|
  sysfun["SYS_FUN"].each do |s|
    if !s["GATE"].nil?
    s["GATE"].each do |g|
      if !g["CHECK"].nil?
      g["CHECK"].each do |n|
        st=stage[n["NAME"]]
        st[n["VALUE"][0]]=[]
        alwaysCall.delete(s["NAME"])
      end
      end
    end
    end
  end
 end

system.each do |sysfun|
  sysfun["SYS_FUN"].each do |s|
    if !s["GATE"].nil?
    s["GATE"].each do |g|
      if !g["CHECK"].nil?
      g["CHECK"].each do |n|
        st=stage[n["NAME"]]
        st[n["VALUE"][0]] << s["NAME"]
        alwaysCall.delete(s["NAME"])
      end
      end
    end
    end
  end
 end
# p stage
# p alwaysCall
pr=File.read('SYS_FUN_iterate_optimized_c.template')
out=File.open('SYS_FUN_iterate_optimized.c','w')
eruby=Erubis::Eruby.new(pr)
out.puts eruby.result(binding())
out.close();
system 'astile.exe -n SYS_FUN_iterate_optimized.c'
