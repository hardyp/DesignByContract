class ZCL_DBC definition
  public
  create public .

public section.

  constants MC_PRODUCTION type T000-CCCATEGORY value 'P' ##NO_TEXT.

  class-methods ENSURE
    importing
      !WHICH_IS_TRUE_IF type ABAP_BOOL
      !THAT type ITEX132 .
  class-methods REQUIRE
    importing
      !WHICH_IS_TRUE_IF type ABAP_BOOL
      !THAT type ITEX132 .
protected section.
private section.

  class-methods IS_PRODUCTION
    returning
      value(RESULT) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_DBC IMPLEMENTATION.


METHOD ensure.
* Local Variables
  DATA: call_stack_list TYPE sys_callst,
        client_program  TYPE dbglprog,
        server_program  TYPE dbglprog,
        client_routine  TYPE dbglevent,"Calling Routine
        server_routine  TYPE dbglevent,"Routine where exception raised
        count           TYPE i.

* Preconditions
  CHECK which_is_true_if = abap_false.
  CHECK is_production( ) = abap_false.

  DATA(log) = zcl_logger=>new( ).

  "Read Call Stack
  CALL FUNCTION 'SYSTEM_CALLSTACK'
    IMPORTING
      et_callstack = call_stack_list[].

  "The call stack works backwards
  LOOP AT call_stack_list ASSIGNING FIELD-SYMBOL(<call_stack>).
    IF <call_stack>-progname CS 'ZCL_DBC'.
      "i.e. we called ourself
      CONTINUE.
    ENDIF.
    count = count + 1."Ha ha ha! Lightning Flashes!
    CASE count.
      WHEN 1.
        server_program = <call_stack>-progname.
        server_routine = <call_stack>-eventname.
      WHEN 2.
        client_program = <call_stack>-progname.
        client_routine = <call_stack>-eventname.
      WHEN OTHERS.
        EXIT."From Loop
    ENDCASE.
  ENDLOOP.

*--------------------------------------------------------------------*
* Listing 04.14: - Building an Error Message
*--------------------------------------------------------------------*
  log->add( :
  |{ 'This Diagnosis is intended for IT'(011) }| ),
  |{ 'Routine'(001) } { server_routine } { 'of program'(002) }{ server_program } { 'has a contract'(003) } | ),
  |{ 'with calling routine'(004) } { client_routine } { 'of program'(002) } { client_program } | ),
  |{ 'Routine'(001) } { server_routine } { 'agrees to carry out a certain task'(005) } | ),
  |{ 'The task is to ensure that'(012) } { that } | ),
  |{ 'That task has not been fulfilled by routine'(013) } { server_routine } | ),
  |{ 'Therefore there is an error (bug) in routine'(008) } { server_routine } { 'that needs to be corrected'(009) } | ).

  RAISE EXCEPTION NEW zcx_violated_postcondition( md_condition = that
                                                  mo_error_log = log ).

ENDMETHOD.


  METHOD is_production.
    "T000 - Fully Buffered
    SELECT SINGLE cccategory
      FROM  t000
      INTO  @DATA(ld_client_function)
      WHERE mandt EQ @sy-mandt.

    IF ld_client_function = mc_production.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.

  ENDMETHOD.


METHOD require.
* Local Variables
  DATA: call_stack_list TYPE sys_callst,
        client_program  TYPE dbglprog,
        server_program  TYPE dbglprog,
        client_routine  TYPE dbglevent, "Calling Routine
        server_routine  TYPE dbglevent, "Routine where exception raised
        count           TYPE i.

  "Preconditions
  CHECK which_is_true_if = abap_false.
  CHECK is_production( ) = abap_false.

  DATA(log) = zcl_logger=>new( ).

  "Read Call Stack
  CALL FUNCTION 'SYSTEM_CALLSTACK'
    IMPORTING
      et_callstack = call_stack_list[].

  "The call stack works backwards
  LOOP AT call_stack_list ASSIGNING FIELD-SYMBOL(<call_stack>).
    IF <call_stack>-progname CS 'ZCL_DBC'.
      "i.e. we called ourself
      CONTINUE.
    ENDIF.
    count = count + 1."Ha ha ha! Lightning Flashes!
    CASE count.
      WHEN 1.
        server_program = <call_stack>-progname.
        server_routine = <call_stack>-eventname.
      WHEN 2.
        client_program = <call_stack>-progname.
        client_routine = <call_stack>-eventname.
      WHEN OTHERS.
        EXIT."From Loop
    ENDCASE.
  ENDLOOP.

  "Please feel free to e-phrase the below so it makes better sense and then tell me!
  log->add( :
  | { 'This Diagnosis is intended for IT'(011) }| ),
  | { 'Routine'(001) } { server_routine } { 'of program'(002) } { server_program } { 'has a contract'(003) }| ),
  | { 'with routine'(015) } { client_routine } { 'of program'(002) } { client_program }| ),
  | { 'Routine'(001) } { server_routine } { 'agrees to carry out a certain task'(005) }| ),
  | { 'This requires that'(006) } { that }| ),
  | { 'That condition has not been fulfilled by calling routine'(007) } { client_routine }| ),
  | { 'and so therefore there is an error (bug) in routine'(014) } { client_routine } { 'that needs to be corrected'(009) }| ).

  RAISE EXCEPTION NEW zcx_violated_precondition( md_condition = that
                                                 mo_error_log = log ).

ENDMETHOD.
ENDCLASS.
