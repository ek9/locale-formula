# Installs and configures system locales

{% from "locale/map.jinja" import map with context %}

locale_pkgs:
  pkg.installed:
    - pkgs:
      {%- for pkg in map.pkgs %}
        - {{ pkg }}
      {% endfor %}

{%- set locales = salt['pillar.get']('locale:present', []) %}
{%- set default = salt['pillar.get']('locale:default', 'en_US.UTF-8') %}

{%- for locale in locales %}
locale_present_{{ locale|replace('.', '_')|replace(' ', '_') }}:
  locale.present:
    - name: {{ locale }}
{%- endfor %}

{% if default is mapping %}
locale_default:
  locale.system:
    - name: {{ default.name }}
    - require:
      - locale: locale_present_{{ default.requires|replace('.', '_')|replace(' ', '_') }}
{% endif %}

{%- set conf = salt['pillar.get']('locale:conf', {}) %}
{%- if conf is iterable %}
locale-conf-is-setup:
  file.managed:
    - name: /etc/locale.conf
    - contents_pillar: locale:conf
{% else %}
{% endif %}

