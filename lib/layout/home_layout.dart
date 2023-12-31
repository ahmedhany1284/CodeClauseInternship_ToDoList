import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/modules/login_screen/login_screen.dart';
import 'package:to_do_list/shared/components/components.dart';
import 'package:to_do_list/shared/cubit/cubit.dart';
import 'package:to_do_list/shared/cubit/states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Homelayout extends StatelessWidget {
  late Database database;

  var scaffoldkey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  var titlecontroller = TextEditingController();

  var timecontroller = TextEditingController();

  var datecontroller = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return BlocProvider (
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDataBaseState) {
            Navigator.pop(context);
          }
          if (state is AuthSignedOut) {
            navigateToAndFinish(context, LoginScreen());
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);


          return Scaffold(
            key: scaffoldkey,
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 2, 0, 83),
              elevation: 5,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cubit.cur_var == 0) Icon(Icons.add_task_sharp),
                  if (cubit.cur_var == 1) Icon(Icons.task_alt),
                  if (cubit.cur_var == 2) Icon(Icons.archive),
                  // Add an icon
                  SizedBox(width: 8), // Add spacing between the icon and text
                  Text(
                    cubit.titles[cubit.cur_var],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [

                IconButton(
                  onPressed: () async {
                    await GoogleSignIn().signOut();
                    await FacebookAuth.instance.logOut();
                    await FirebaseAuth.instance.signOut();

                    cubit.signOut();
                    showCustomToast("Signed Out Successfully");
                  },
                  icon: Icon(Icons.power_settings_new),
                ),

              ],
            ),
            body: Container(

              child: ConditionalBuilder(
                condition: state is! AppGetDataBaseLoadingState,
                builder: (context) => cubit.screen[cubit.cur_var],
                fallback: (context) =>
                    Center(child: CircularProgressIndicator()),
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.fromARGB(255, 2, 0, 83),
                    hexStringToColor("aB2B93"),
                    hexStringToColor("7546C4"),
                    hexStringToColor("5E61F6"),
                    Color.fromARGB(255, 2, 0, 83),
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Color.fromARGB(255, 254, 151, 91),
              onPressed: () {
                if (cubit.isBottomsheeetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDatabase(
                      title: titlecontroller.text,
                      time: timecontroller.text,
                      date: datecontroller.text,
                    );
                    titlecontroller.text = '';
                    timecontroller.text = '';
                    datecontroller.text = '';
                  }

                }
                else {
                  scaffoldkey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  readonly: false,
                                  controller: titlecontroller,
                                  type: TextInputType.text,
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'title must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task Title',
                                  icon: Icons.title,
                                ),
                                SizedBox(height: 15.0),
                                defaultFormField(
                                  readonly: true,
                                  controller: timecontroller,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value) {
                                      timecontroller.text =
                                          value!.format(context).toString();
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'time must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task Time',
                                  icon: Icons.watch_later_outlined,
                                ),
                                SizedBox(height: 15.0),
                                defaultFormField(
                                  readonly: true,
                                  controller: datecontroller,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate:
                                          DateTime(DateTime.now().year + 15),
                                    ).then((value) {
                                      datecontroller.text =
                                          DateFormat.yMMMd().format(value!);
                                    });
                                  },
                                  validate: (value) {
                                    if (value!.isEmpty) {
                                      return 'date must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task date',
                                  icon: Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  });
                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabicon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: true,
              showUnselectedLabels: false,
              backgroundColor: Color.fromARGB(255, 64, 68, 204),
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.cur_var,
              onTap: (index) {
                cubit.change_Index(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                    color: Colors.white,
                  ),
                  label: 'Archieved',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
