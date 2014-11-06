# Playbook

Create playbook from text

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'playbook', :git => 'https://github.com/sumipan/playbook.rb.git', :branch => 'master'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install

## Usage

Sample playbook text

Playbook 読み込まれたテキスト内の \```book で始まって \``` で終わるまでをブックとして扱います。

<pre>
これはサンプルです。
このような書き方でシナリオを記述してください。

```book
scene: シーン1
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに猫が近づく
scene: シーン2
scenario: すやすやイルカが目を覚ます
```

章を含める場合は ```chapter``` を追加

```book
chapter: 第一章
scene: シーン3
scenario: すやすやイルカが眠っている
scenario: すやすやイルカに犬が近づく
scene: シーン4
scenario: すやすやイルカが眠そうにしている
```
</pre>

In ruby

```ruby
require 'playbook'

playbook = Playbook.parse(raw_text)
playbook.chapters.first.scenes.each do |scene|
  scene.scenarios.each do |scenario|
    scenario.text
  end
end
```

Github integration

```ruby
Playbook::Github.configure do |github|
  github.setup({
    :user => 'username',
    :repo => 'reponame',
    :oauth_token => 'your api token',
  })
end

playbook = GithubPlaybook.parse(issue_number)
```

## Contributing

1. Fork it ( https://github.com/sumipan/playbook.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
