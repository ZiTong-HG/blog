<div class="logo-wrapper">
  <a href="{{ url_for('.') }}" class="logo">{{ config.title }}'s Blog</a>
</div>

<nav class="site-navbar">
  {% if theme.menu %}
    <ul id="menu" class="menu">
      {% for name, path in theme.menu %}
        <li class="menu-item"></i>
          <a class="menu-item-link" href="{{ url_for(path) }}">
            {% if name === 'Home' %}
              <i class="{{theme.menuicon.Home}}" style="margin-right: 5px;"></i>
            {% elseif  name === 'Archives' %}
              <i class="{{theme.menuicon.Archives}}" style="margin-right: 5px;"></i>
            {% elseif name === 'Tags' %}
              <i class="{{theme.menuicon.Tags}}" style="margin-right: 5px;"></i> 
            {% elseif name === 'Categories' %}
              <i class="{{theme.menuicon.Categories}}" style="margin-right: 5px;"></i> 
            {% elseif name === 'About' %}
              <i class="{{theme.menuicon.About}}" style="margin-right: 5px;"></i> 
            {% endif %}  
            {% set itemName = __('menu.' + name.toLowerCase()) %}
            {% if itemName.startsWith('menu') %}
              {{ name }}
            {% else %}
              {{ itemName }}
            {% endif %}
          </a>
        </li>
      {% endfor %}
    </ul>
  {% endif %}
</nav>
