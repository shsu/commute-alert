class Incident
  @events = ['accident', 'block', 'broken', 'clos', 'collision', 'crash', 
  'delay', 'disruption', 'incident', 'multi-vehicle', 'problem', 'mva', 
  'mvi', 'stall']

  def self.isHighway91?(msg)
    ['hwy91', 'hwy 91', 'alexfraser'].any? { |highway| msg.include? highway } && 
      @events.any? { |event| msg.include? event }
  end

  def self.isHighway99?(msg)
    ['hwy99', 'hwy 99', 'massey'].any? { |highway| msg.include? highway } && 
      @events.any? { |event| msg.include? event }
  end

  def self.isSkytrain?(msg)
    msg.include?('skytrain') && @events.any? { |event| msg.include? event }
  end
end
