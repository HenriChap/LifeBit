version 1.0
## ! a task only wdl file may be used for exporting tasks to other files
task taskA {
  input {
    File inputFile
  }
  command <<<
   ... 
  >>>
  output { 
    File out
  }
}

task taskB {
  input {
    Array[File] files
  }
  command <<<
   ... 
  >>>
  output { 
    File out 
    String id

  }
}

task taskC {
  input {
    File inputResults
    String inputId
  }
  command <<<
   ... 
  >>>
  output { 
    File outputName

  }
}