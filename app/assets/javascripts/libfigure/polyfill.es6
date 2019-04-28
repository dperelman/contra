// GENERATED FILE - source is in "/home/dm/contra/app/javascript/libfigure/polyfill.js" - regenerate this with bin/rake libfigure:compile
/***/ if (!Array.prototype.findIndex) {
/***/   Array.prototype.findIndex = function(predicate) {
/***/     'use strict';
/***/     if (this == null) {
/***/       throw new TypeError('Array.prototype.findIndex called on null or undefined');
/***/     }
/***/     if (typeof predicate !== 'function') {
/***/       throw new TypeError('predicate must be a function');
/***/     }
/***/     var list = Object(this);
/***/     var length = list.length >>> 0;
/***/     var thisArg = arguments[1];
/***/     var value;
/***/ 
/***/     for (var i = 0; i < length; i++) {
/***/       value = list[i];
/***/       if (predicate.call(thisArg, value, i, list)) {
/***/         return i;
/***/       }
/***/     }
/***/     return -1;
/***/   };
/***/ }
