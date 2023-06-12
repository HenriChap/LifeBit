version 1.0

## ! Before starting, remember to setup your enviroment with an engine (each with its requeriments) and Docker. Suggest to start with cromwell or miniwdl. 

import <path/file> as task_Z ## ! A good pratice to reuse code and improve maintenance. Remember to keep your WDL short.


meta {## § Optional component "meta". For authoring and description. Can be written at multiple parts of the wdl.
   author: "Herique Chapola"
   email: "henriquechapola@gmail.com"
   description:
   "A instructive wdl file for developers, filled with MANY commentaries, for easily find concepts (§) and tips (!).
   Here is described: 
   Simple workflow with a condidional
   Workflow with multiple parameters and Plumbing"
 }


## ! For best pratice, start your file with the workflow, containing inputs and tasks. Then describe the task, with inputs, commands, runtime (optional but reccommended) and outputs.

workflow BasicWorkflow { ## § Top-level component "workflow". USed for  ! Keep one per wdl file as best pratice. Note: in this file there will be mutiple workflows.
  
  meta {
     name: "Simple workflow"
     description: "A simple workflow with one task, called two time, and using all opitional components"
  }
  
  parameter_meta{ ## § Opitional core-level component "parameter_meta". Use to describe inputs or outputs from workflow and tasks. Names MUST correspond to its section
     my_ref: {
          description: "A reference file",
          pattern:"*.ref"
     }
     my_input: {## ! You can add everything you what. But remember, keep your wdl short and cocise.
          description: "Input file",
          any_annotation:"Any observation here",
          
     }

  }
  input { ## § Core-level component "input". Hard-type variables as primitive types (String, Boolean, Float, Int and File) or complex types (Array, Pair, Map, Object)
    File my_ref
    File my_input
    Boolean is_name
    String? name = basename(my_input, ".bam") ( ## ! The "?" set the variable as optional, and "=" set a default value. § basename(), a function with two arguments: where to extract a string, and what to strip off. In this case, the name will be whatever my_input file is named without ".bam" 
}
  if(is_name) { ## § WDL only have conditional "if", and take boolean values to execute the following instruction.
     call task_A as FirstTimeTask {## § Top-level component "call". Call tasks inputs corresponding to workflow's. Input names have to be the same from task_A description, as shown further. § You can use "as" to alias a task.
          input: 
          ref = my_ref,
          in = my_input,
          id = name     
     }
  }
  if(!is_name) { ## § The sign "!" is a modifier to reverse a Boolean value.
     call task_A as FirstTimeTask {## § Top-level component "call". Call tasks inputs corresponding to workflow's. Input names have to be the same from task_A description, as shown further. § You can use "as" to alias a task.
          input: 
          ref = my_ref,
          in = my_input,
          id = "file" ## ! 
     }
  }
}

## ! Describe task(s) after the workflow

task task_A { ## § Top-velel component "task". Define a programmatic task
  input { ##Remember to double-check if input names from this c
    File ref
    File in
    String id
  }
  command <<< ## § Core-level component "command". A shell script with your algorithm using "~{}" to add variables
    do_stuff -R ~{ref} -I ~{in} -O ~{id}.ext
  >>>
  runtime { ## § Optional core-level "runtime". Set the docker image necessary to run your wdl. Some good image repositories are Dockstore, Dockerhub and quay.io
    docker: "ubuntu:latest"
  }
  output { ## § Core-level component "output". Show the expected output. Also hard-typed.
    File out = "~{id}.ext"
  }
}

## Workflow with multiple parameters and plumbing

workflow ComplexWorkflow { ## ! Remember keep one per wdl file as best pratice. Separete workflows in different files
  
  meta {
     name: "Plumbed Workflow "
     description: "This worflow explores how to deal with and connect multiple inputs and output for greater complexity."
  }
  input{
     Array 
  }
}
## ! To run your wdl depends on your engine of choice. Explore the documentation.
