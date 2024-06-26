<p align="center">
	<img width="75" alt="LesliSupport logo" src="./app/assets/images/lesli_support/support-logo.svg" />
    <h3 align="center">Support Ticket System for the Lesli Framework</h3>
</p>

<hr/>
<p align="center">
    <a target="blank" href="https://rubygems.org/gems/lesli_support">
        <img height="22" alt="Gem Version" src="https://badge.fury.io/rb/lesli_support.svg" />
    </a>
</p>
<hr/>


### Quick start

```shell
# Add LesliSupport engine
bundle add lesli_support
```

```shell
# Setup database
rake lesli:db:setup
```

```ruby
# Load LesliSupport
Rails.application.routes.draw do
    mount LesliSupport::Engine => "/help"
end
```


### Documentation
* [website](https://www.lesli.dev/support/)
* [database](./docs/database.md)
* [documentation](https://www.lesli.dev/documentation/)


### Get in touch with Lesli

* [Website: https://www.lesli.tech](https://www.lesli.tech)
* [Email: hello@lesli.tech](hello@lesli.tech)
* [Twitter: @LesliTech](https://twitter.com/LesliTech)


### License
-------
Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

<hr />
<br />

<p align="center">
    <img width="200" alt="Lesli logo" src="https://cdn.lesli.tech/lesli/brand/app-logo.svg" />
    <h4 align="center">Ruby on Rails SaaS Development Framework.</h4>
</p>

