require 'spec_helper'

describe MoviesHelper do
  describe 'oddness' do
    it 'should return correct oddness result for odd number' do
      oddness(3).should == 'odd'
    end
    it 'should return correct oddness result for even number' do
      oddness(4).should == 'even'
    end
  end
end