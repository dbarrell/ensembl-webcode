/*
 * Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

Ensembl.Panel.MultiSelector = Ensembl.Panel.extend({
  constructor: function (id, params) {
    this.base(id);
    this.urlParam = params.urlParam;
    this.paramMode = params.paramMode;
    console.log(this.urlParam, this.paramMode)
    Ensembl.EventManager.register('updateConfiguration', this, this.updateSelection);
  },
  
  init: function () {
    var panel = this;
    
    this.base();
    
    this.initialSelection = '';
    this.selection        = [];
    
    this.elLk.content = $('.modal_wrapper',       this.el);
    this.elLk.list    = $('.multi_selector_list', this.elLk.content);
    
    var ul    = $('ul', this.elLk.list);
    var spans = $('span', ul);
    this.elLk.lis = $('li', ul);

    this.elLk.spans    = spans.filter(':not(.switch)');
    this.elLk.form     = $('form', this.elLk.content);
    this.elLk.included = ul.filter('.included');
    this.elLk.excluded = ul.filter('.excluded');
    
    this.setSelection(true);
    this.updateTitleCount();
    
    this.elLk.included.sortable({
      containment: this.elLk.included.parent(),
      stop: $.proxy(this.setSelection, this)
    });

    this.buttonWidth = this.elLk.lis.on('click', function () {
      $(this).toggleClass('selected');
      panel.setSelection();

      panel.updateTitleCount();
    });

    this.buttonWidth = spans.width();
    
    $('.select_by select', this.el).on('change', function () {
      var toAdd, toRemove;
      
      switch (this.value) {
        case ''    : break;
        case 'all' : toAdd    = panel.elLk.excluded.children(); break;
        case 'none': toRemove = panel.elLk.included.children(); break;
        default    : toAdd    = panel.elLk.excluded.children(':contains(' + this.options[this.selectedIndex].innerHTML + ')'); 
                     toRemove = panel.elLk.included.children().not(':contains(' + this.options[this.selectedIndex].innerHTML + ')'); break;
      }
      
      if (toAdd) {
        panel.elLk.included.append(toAdd);
      }
      
      if (toRemove) {
        toRemove.add(panel.elLk.excluded.children()).detach().sort(function (a, b) { return $(a).text() > $(b).text(); }).appendTo(panel.elLk.excluded);
      }
      
      panel.setSelection();
      panel.updateTitleCount();
      toAdd = toRemove = null;
    });
    
    ul = null;
  },
  
  updateTitleCount: function() {
    var panel = this;
    var unselected_count = this.elLk.lis.filter('.selected').length;
    this.el.find('._unselected_species .count').html(unselected_count);
  },
  
  setSelection: function (init) {
    var panel = this;

    panel.selection = [];
    panel.elLk.lis.filter('.selected').each(function(i, val) {
      panel.selection.push($(val).find('span').attr('class'));
    });

    if (init === true) {
      var url_params = {};
      var test = '^' + this.urlParam + '[0-9]*$';
      var re = new RegExp(test, 'g');
      $.each(window.location.search.replace(/^\?/, '').split(/[;&]/), function (i, part) {
        var kv = part.split('=');
        if (!kv[0].match(re)) {
          return;
        }

        url_params[kv[0]] = kv[1];
      });

      $.each(url_params, function(i, val) {
        panel.elLk.spans.filter('.'+val).closest('li').addClass('selected');
      });
      this.initialSelection = this.selection.join(',');
    }
  },
  
  updateSelection: function () {
    var panel = this;
    var params = [];
    var i;

    if(this.paramMode === 'single') {
      params.push(this.urlParam + '=' + this.selection);
    } else {
      for (i = 0; i < this.selection.length; i++) {
        params.push(this.urlParam + (i + 1) + '=' + this.selection[i]);
      }
    }
    
    if (this.selection.join(',') !== this.initialSelection) {
      Ensembl.redirect(this.elLk.form.attr('action') + '?' + Ensembl.cleanURL(this.elLk.form.serialize() + ';' + params.join(';')));
    }
    
    return true;
  }
});
