<!DOCTYPE html>
<html lang="{{ config.language }}">
  <head>
    {% include '_partial/head.swig' %}
    <title>{% block title %}{% endblock %}</title>
  </head>

  <body>
    {%- include '_partial/slideout.swig' %}
    <header id="header" class="header">
      <div class="header-inner">
        {%- include '_partial/header.swig' %}
      </div>
    </header>
    <div class="container" id="mobile-panel">
      <main id="main" class="main">
        <div class="content-wrapper">
          <div id="content" class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_partial/comments.swig' %}
        </div>
      </main>

      <footer id="footer" class="footer">
        {%- include '_partial/footer.swig' %}
      </footer>

      <div class="back-to-top" id="back-to-top">
        <i class="iconfont icon-up"></i>
      </div>
    </div>

    {% include '_script/comments.swig' %}

    {% include '_script/libs.swig' %}
    {% include '_script/theme.swig' %}
  </body>
</html>
