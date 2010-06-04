if (typeof RT == "undefined") RT = {};

RT.Vote = Class.create({
  initialize: function() {
    this.form = $('vote').down('form');
    this.timer = $('timer');
    // this.updateChecked();
    S2.UI.disableTextSelection($('vote'));
    this.addObservers();
  },
  
  addObservers: function() {
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
  
  submit: function() {
    this.form.addClassName('submitting');  // TODO actually disable.
    this.form.request();
    this.startTimer();
  },
  
  startTimer: function() {
    var seconds = 2;
    this.updateTimer(seconds);
    this.timer.show();
    new PeriodicalExecuter(function(executer) {
      seconds = seconds - 1;
      if (seconds > 0) {
        this.updateTimer(seconds);
      } else {
        executer.stop();
        this.timer.hide();
        this.form.removeClassName('submitting');
        this.form.reset();
        this.updateChecked();
      }
    }.bind(this), 1);
  },
  
  updateTimer: function(seconds) {
    this.timer.update('You can vote again in ' + seconds + ' second' + (seconds == 1 ? '' : 's') + '.');
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
    this.submit();
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
    if (code === Event.KEY_RETURN || code === Event.KEY_SPACE) {
      var label = $(document.activeElement).up();
      if (!label.match('label')) {
        label = this.form.select('label.hover').last();
      }
      if (label) {
        label.addClassName('active');
      }
    }
  },
  
  keyup: function(event) {
    var code = event.keyCode;
    if (code === Event.KEY_RETURN || code === Event.KEY_SPACE) {
      var label = this.form.down('label.active');
      if (label) {
        label.removeClassName('active');
        label.down('input').setValue(true);
        this.updateChecked();
        this.submit();
      }
    }
  },
  
  touchstart: function(event, label) {
    label.addClassName('active');
    label.previousSiblings().concat(label).invoke('addClassName', 'hover');
  },
  
  touchmove: function(event) {
    if (event.targetTouches.length == 1) {
      var offset = this.form.viewportOffset();
      this.touchX = event.targetTouches[0].clientX - offset.left;
      this.touchY = event.targetTouches[0].clientY - offset.top;
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
    var activated = (label && this.touchX > 0 && this.touchX < layout.get('width') && 
      this.touchY > 0 && this.touchY < layout.get('height'));
    if (activated) {
      label.down('input').setValue(true);
      this.updateChecked();
    }
    this.form.select('label').invoke('removeClassName', 'active').invoke('removeClassName', 'hover');
    if (activated) {
      this.submit();
    }
  }
});

new RT.Vote();