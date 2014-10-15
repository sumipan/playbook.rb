# encoding: utf-8

require 'minitest/autorun'
require 'playbook'

describe Playbook do
	it "" do
		raw_text = <<RAW_TEXT
これはサンプルです。
このような書き方でシナリオを記述してください。

```book
scene: シーン1
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに猫が近づく
scene: シーン2
scenario: すやすやイルカが目を覚ます
```

```book
scene: シーン3
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに犬が近づく
scene: シーン4
scenario: すやすやイルカが眠そうにしている
```

RAW_TEXT

		playbook = Playbook.parse(raw_text)
		playbook.must_be_instance_of Playbook::Book

		playbook.scenes.each do |scene|
			scene.must_be_instance_of Playbook::Scene

			scene.name.must_match(/^シーン\d$/)

			scene.scenarios.each do |scenario|
				scenario.must_be_instance_of Playbook::Scenario
				scenario.text.must_match(/^すやすやイルカ/)
			end
		end

		playbook.scenes.size.must_equal 4
		scene = playbook.scenes.select{|s| s.name == 'シーン4' }.first
		scene.scenarios.size.must_equal 1

raw_text = <<RAW_TEXT
これはサンプルです。
このような書き方でシナリオを記述してください。

```book
scene: シーン4
scenario: すやすやイルカは眠ってしまった
scene: シーン5
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに猫が近づく
scenario: すやすやイルカがびっくりして飛び起きた
```
RAW_TEXT

		playbook2 = Playbook.parse(raw_text)
		playbook3  = playbook.merge(playbook2)
		playbook3.must_equal playbook

		playbook.scenes.size.must_equal 5
		scene = playbook.scenes.select{|s| s.name == 'シーン4' }.first
		scene.scenarios.size.must_equal 2
	end
end
