require 'json'

class Dance < ActiveRecord::Base
  belongs_to :user
  belongs_to :choreographer
  validates :title, length: { in: 3..100 }
  validates :start_type, length: { in: 1..100 }
  accepts_nested_attributes_for :choreographer

  scope :alphabetical, ->() { order "LOWER(title)" }
  scope :readable_by, ->(user=nil) {
    if user.nil?
      where(publish: true)
    elsif user.admin?
      all
    else
      where('publish= true OR user_id= ?', user.id)
    end
  }

  def readable?(user=nil)
    publish || user_id == user&.id || user&.admin? || false
  end

  def figures
    JSON.parse figures_json
  end
  # eases form defaulting:
  def choreographer_name () choreographer ? choreographer.name : "" end
  # legacy functions - should not be called anymore:
  def figure1 () JSON.generate (figures[0]||{}); end
  def figure2 () JSON.generate (figures[1]||{}); end
  def figure3 () JSON.generate (figures[2]||{}); end
  def figure4 () JSON.generate (figures[3]||{}); end
  def figure5 () JSON.generate (figures[4]||{}); end
  def figure6 () JSON.generate (figures[5]||{}); end
  def figure7 () JSON.generate (figures[6]||{}); end
  def figure8 () JSON.generate (figures[7]||{}); end

  # Returns a hash. Keys are moves (strings). Values are dances containing that figure.
  def self.move_index(dances)
    moves_dances = {}
    dances.each do |dance|
      dance.figures.each do |figure|
        move = JSLibFigure.move figure
        moves_dances[move] ||= Set.new
        moves_dances[move] << dance
      end
    end
    moves_dances
  end
end
