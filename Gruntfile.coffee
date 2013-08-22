module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-release')

  grunt.config.init
    pkg: grunt.file.readJSON "package.json"
    coffee:
      default:
        files:
          "build/angular-datepicker.js": "src/angular-datepicker.coffee"
    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      build:
        src: 'build/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'
    release:
      options:
        npm: false
    watch:
      scripts:
        files: ['src/*.coffee']
        tasks: ['coffee']



  grunt.registerTask "default", ["coffee", "uglify"]
