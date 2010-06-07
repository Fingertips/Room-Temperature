if (typeof RT == "undefined") RT = {};

RT.Stars = Class.create({
  initialize: function(form) {
    this.form = $(form);
    this.updateChecked();
    S2.UI.disableTextSelection($('vote'));
    
    if (!Prototype.Browser.MobileSafari) {
      this.form.on('mousedown', 'label', this.down.bind(this));
      this.form.on('mouseup', 'label', this.up.bind(this));
      $(document).on('mouseup', this.upOutside.bind(this));
      this.form.on('mouseover', 'label', this.over.bind(this));
      this.form.on('mouseout', 'label', this.out.bind(this));
      $(document).on('keydown', this.keydown.bind(this));
      $(document).on('keyup', this.keyup.bind(this));
    } else {
      $(document.body).on('touchmove', 'label', function(event) { event.preventDefault(); });
      this.form.on('touchstart', 'label', this.touchstart.bind(this));
      this.form.on('touchmove', 'label', this.touchmove.bind(this));
      this.form.on('touchend', 'label', this.touchend.bind(this));
      // this.form.on('touchcancel', 'label', function() { alert('cancel'); });
    }
  },
  
  updateChecked: function() {
    var field = this.form.down('input[checked]');
    if (field) {
      var label = field.up('label');
      label.siblings().invoke('removeClassName', 'checked');
      label.addClassName('checked');
      label.previousSiblings().invoke('addClassName', 'selected');
      label.nextSiblings().invoke('removeClassName', 'selected');
    } else {
      this.form.select('label').invoke('removeClassName', 'checked').invoke('removeClassName', 'selected');
    }
  },
  
  down: function(event, label) {
    this.isDown = true;
    label.addClassName('active');
  },
  
  up: function(event, label) {
    this.isDown = false;
    label.down('input').setValue(true);
    this.updateChecked();
  },
  
  upOutside: function() {
    this.isDown = false;
    this.form.select('label').invoke('removeClassName', 'active').invoke('removeClassName', 'hover');
  },
  
  over: function(event, label) {
    this.form.select('div').invoke('blur');
    if (this.isDown) {
      label.addClassName('active');
    }
    label.previousSiblings().concat(label).invoke('addClassName', 'hover');
  },
  
  out: function(event, label) {
    this.form.select('label.active').invoke('removeClassName', 'active');
    this.form.select('label.hover').invoke('removeClassName', 'hover');
  },
  
  keydown: function(event) {
    var code = event.keyCode;
    if (code === Event.KEY_TAB) {
      this.form.select('label.hover').invoke('removeClassName', 'hover');
    } else if (code === Event.KEY_RETURN) {
      var label = $(document.activeElement).up();
      if (!label.match('label')) {
        label = this.form.select('label.hover').last();
      }
      if (label) {
        label.addClassName('active');
        console.log('Active');
      }
    }
  },
  
  keyup: function(event) {
    var code = event.keyCode;
    if (code === Event.KEY_RETURN) {
      var label = this.form.down('label.active');
      if (label) {
        label.removeClassName('active');
        label.down('input').setValue(true);
        this.updateChecked();
      }
    }
  },
  
  setTouchPosition: function(event) {
    var offset = this.form.viewportOffset();
    this.touchX = event.targetTouches[0].clientX - offset.left;
    this.touchY = event.targetTouches[0].clientY - offset.top;
  },
  
  touchstart: function(event, label) {
    this.setTouchPosition(event);
    label.addClassName('active');
    label.previousSiblings().concat(label).invoke('addClassName', 'hover');
  },
  
  touchmove: function(event) {
    if (event.targetTouches.length == 1) {
      this.setTouchPosition(event);
      var label = this.form.select('label').detect(function(label) {
        if (this.touchX > 0 && this.touchX < (label.measure('left') + label.measure('width'))) {
          return label;
        }
      }.bind(this));
      if (label) {
        label.addClassName('active');
        label.siblings().invoke('removeClassName', 'active');
        label.previousSiblings().concat(label).invoke('addClassName', 'hover');
        label.nextSiblings().invoke('removeClassName', 'hover');
      }
    }
  },
  
  touchend: function(event, label) {
    var label = this.form.select('label.hover').last();
    var layout = this.form.getLayout();
    if (label && this.touchX > 0 && this.touchX < layout.get('width') && this.touchY > 0 && this.touchY < layout.get('height')) {
      label.down('input').setValue(true);
      this.updateChecked();
    }
    this.form.select('label').invoke('removeClassName', 'active').invoke('removeClassName', 'hover');
  }
});