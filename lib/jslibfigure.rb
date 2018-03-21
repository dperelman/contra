# API for talking to figures from rails, using the same logic that is used in the client-side JS code

module JSLibFigure

  def self.figureToString(figure_ruby_hash, dialect)
    self.eval("figureToString(#{figure_ruby_hash.to_json},#{dialect.to_json})")
  end

  def self.beats(figure_ruby_hash)
    self.eval("figureBeats(#{figure_ruby_hash.to_json})")
  end

  def self.new
    self.eval('newFigure()')
  end

  def self.move(figure_ruby_hash)
    figure_ruby_hash['move']
  end

  def self.is_move?(move)
    move.in?(moves)
  end

  def self.moves
    @moves ||= self.eval('moves()')
  end

  def self.move_terms_and_substitutions(dialect)
    self.eval("moveTermsAndSubstitutions(#{dialect.to_json})")
  end

  def self.de_alias_move(move_str)
    self.eval("deAliasMove(#{move_str.inspect})")
  end

  def self.aliases(move_str)
    self.eval("aliases(#{move_str.inspect})")
  end

  def self.related_moves(move_str)
    self.eval("relatedMoves(#{move_str.inspect})")
  end

  def self.teaching_name(move_string)
    move_string ? self.eval("teachingName(#{move_string.inspect})") : "empty figure"
  end

  def self.angles_for_move(move_string)
    self.eval("anglesForMove(#{move_string.inspect})")
  end

  def self.degrees_to_words(degrees, optional_move=nil)
    if optional_move
      self.eval("degreesToWords(#{degrees}, #{optional_move.inspect})")
    else
      self.eval("degreesToWords(#{degrees})")
    end
  end

  def self.formal_parameters(move_string)
    @formal_parameters ||= {}
    @formal_parameters[move_string] ||= self.eval("parameters(#{move_string.inspect})")
  end

  def self.sanitize_json(figures_json_string)
    # some crap is silently stripped (because angular adds crap)
    # other crap raises an error (because we should know about it)
    parsed = JSON.parse(figures_json_string)
    case parsed
    when Array
      JSON.generate(
        parsed.map do |figure|
          f2 = {}
          raise 'figures_json element is not a hash' unless figure.instance_of? Hash
          pvs = figure['parameter_values']
          f2['parameter_values'] = ensure_array_of_terminal(pvs) if pvs
          move = figure['move']
          f2['move'] = ensure_string(move) if move
          note = figure['note']
          f2['note'] = ensure_string(note) if note
          f2
        end)
    else
      raise 'client submitted figures_json was not an array'
    end
  end

  def self.slugify_move(move)   # see also the very similar function slugifyTerm in javascript
    move.gsub('&','and').gsub(' ','-').downcase.gsub(/[^a-z0-9-]/,'').html_safe
  end

  def self.deslugify_move(slug)
    # sorry for the regexp
    # split..join takes the string apart, and allows punctuation between any character, and puts it back together
    # split(_,-1) tacks a null string on the end of the split
    # unshift '' tacks a null string on the beginning of the split
    regexp = /\A#{slug.gsub('-and-', ' & ').gsub('-',' ').split('',-1).tap {|s| s.unshift ''}.join("[^a-z0-9]*")}\z/i
    moves.find {|move| regexp =~ move}
  end

  def self.wrist_grips
    self.eval("wristGrips;")
  end

  def self.parameter_uses_chooser(formal_parameter, chooser_name_string)
    formal_parameter['ui'] == chooser_name_string; # 'should' be compared with address-equals in javascript land, but this is faster
  end

  def self.test_dialect
    @test_dialect ||= self.eval("testDialect;")
  end

  def self.default_dialect
    @default_dialect ||= self.eval("defaultDialect;")
  end

  def self.dialect_for_figures(dialect, figures)
    self.eval("dialectForFigures(#{dialect.to_json},#{figures.to_json})")
  end

  def self.move_substitution(move_term, dialect)
    # js implementation:
    # self.eval("moveSubstitution(#{move_term.inspect}, #{dialect.to_json})")
    # ruby implementation:
    dialect.dig('moves', move_term) || move_term
  end

  def self.dancers_category(dancers)
    @dancers_category_hash ||= self.eval('dancersCategoryHash');
    @dancers_category_hash[dancers] || dancers;
  end

  def self.formal_param_is_dancers(formal_param)
    # there's a ruby-side implementation of this, if we need it for performance
    self.eval("formalParamIsDancers(#{formal_param.to_json})")
  end

  def self.dancers
    self.eval("dancers()")
  end


  JSLIBFIGURE_FILES = %w(polyfill.js util.js move.js chooser.js param.js define-figure.js figure.es6 after-figure.js dance.js)

  private
  def self.eval(string_of_javascript)
    context.eval(string_of_javascript)
  end

  def self.context
    @context || (@context = self.new_context)
  end

  def self.new_context
    context = MiniRacer::Context.new
    JSLIBFIGURE_FILES.each do |file|
      context.load(Rails.root.join('app','assets','javascripts','libfigure',file))
    end
    context
  end

  def self.ensure_array_of_terminal(ary)
    case ary
    when Array
      ary.map {|x| ensure_terminal x}
    else raise 'client submitted json was unexpectedly not an array'
    end
  end

  def self.ensure_terminal(x)
    [FalseClass, TrueClass, NilClass, Integer, String, Float].each do |cls|
      return x if x.instance_of? cls
    end
    raise "expecting Bool, Int, Nil, or String, but got #{x.class.name}"
  end

  def self.ensure_string(s)
    if s.instance_of?(String) then s
    else raise 'client submitted json was unexpectedly not string'
    end
  end
end
