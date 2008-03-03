require 'erb'

module ApplicationHelper
  def short_rev(rev)
    rev.to_s[0..7]
  end
  
  def git
    @git ||= Git.new
  end
end

class ERBStdout < ERB
  def set_eoutvar(compiler, eoutvar = 'STDOUT')
    compiler.put_cmd = "#{eoutvar} << "
    compiler.insert_cmd = "#{eoutvar} << " if compiler.respond_to?(:insert_cmd)
    compiler.pre_cmd = "#{eoutvar}.flush"
    compiler.post_cmd = "#{eoutvar}.flush; ''"
  end
  
  def run(b=TOPLEVEL_BINDING)
    self.result(b)
  end
end

module HtmlHelpers
  include ERB::Util
  include CommonFormatters
  
  def initialize(*params, &block)
    @stdout = STDOUT
    layout {yield self} if block_given?
  end
  
  def path_for(default_path, path)
    if path.include?("/")
      path
    else
      default_path(path)
    end
  end
  
  def layout(&block)
    render("layout", &block)
  end
  
protected  
  def resource_url(filename)
    "file://#{ENV['TM_BUNDLE_SUPPORT']}/resource/#{filename}"
  end
  
  def select_box(name, select_options = [], options = {})
    options[:name] ||= name
    options[:id] ||= name
    # puts select_options.inspect
    <<-EOF
      <select name='#{options[:name]}' id='#{options[:id]}' onchange="#{options[:onchange]}" style='width:100%'>
        #{select_options}
      </select>
    EOF
  end

  def options_for_select(select_options = [], selected_value = nil)
    output = ""
  
    select_options.each do |name, val|
      selected = (val == selected_value) ? "selected='true'" : ""
      output << "<option value='#{val}' #{selected}>#{htmlize(name)}</option>"
    end
  
    output
  end
  
  def make_non_breaking(output)
    htmlize(output.to_s.strip).gsub(" ", "&nbsp;")
  end
  
  
  def htmlize_attr(str)
    str.to_s.gsub(/"/, "&quot;").gsub("<", "&lt;").gsub(">", "&gt;")
  end
  
  def e_js(str)
    str.to_s.gsub(/"/, '\"').gsub("\n", '\n')
  end
  
  def javascript_include_tag(*params)
    file_names = []
    params = params.map {|p| p.include?(".js") ? p : "#{p}.js"}
    params.map do |p|
      %Q{<script type='text/javascript' src="#{resource_url(p)}"></script>}
    end
  end
end

ApplicationHelper.send :include, HtmlHelpers