# encoding: utf-8

require 'minitest/autorun'
require 'playbook'

describe Playbook do
  before do
    @text = <<EOF
元のprは #5729

----
```book
chapter: チャプター 1
scene: シーン 1
scenario: すやすやいるか それはすべてをいやす存在
```
EOF
  end

  it "should not parse error" do
    playbook = Playbook.parse(@text)
    playbook.must_be_instance_of Playbook::Book

    playbook.chapters.size.must_equal 1
    chapter = playbook.chapters.first
    chapter.name.must_equal 'チャプター 1'
    chapter.scenes.size.must_equal 1
    scene = chapter.scenes.first
    scene.name.must_equal 'シーン 1'
    scene.scenarios.size.must_equal 1
    scene.scenarios.first.text.must_equal 'すやすやいるか それはすべてをいやす存在'
  end
end
