<div class="documentation-header">
	<img alt="Lesli Support logo" src="../app/assets/images/lesli_support/support-logo.svg" />
    <h1 align="center">Support Ticket System for the Lesli Framework</h1>
</div>

<hr/>
<p align="center">
    <a target="blank" href="https://rubygems.org/gems/lesli_shield">
        <img src="https://badge.fury.io/rb/lesli_shield.svg" alt="Gem Version" height="24">
    </a>
</p>
<hr/>

### Quick start

```shell
# Add LesliShield engine
bundle add lesli_shield
```

```shell
# Setup database
rake lesli:db:setup
```

```ruby
# Load LesliShield
Rails.application.routes.draw do
    mount LesliShield::Engine => "/shield"
end
```
