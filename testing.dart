import 'package:flutter/material.dart';

import '../timesheet/custom_widget/free_scroll_view.dart';
import 'custom_dialog.dart';

class TestingCustomDialog extends StatelessWidget {
  const TestingCustomDialog({super.key});

  @override
  Widget build(BuildContext bigContext) {
    return Scaffold(
      body: FreeScrollView(
        child: Container(
          height: 1600,
          width: 2000,
          color: Colors.red.withOpacity(0.5),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Text('top left'),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Text('top left'),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Text('top left'),
              ),
              Positioned(
                bottom: 00,
                right: 0,
                child: Text('top left'),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 300,
                  width: 300,
                  color: Colors.blue.withOpacity(0.5),
                  child: Center(
                    child: Builder(
                      builder: (ctxt) {
                        return GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: bigContext,
                                  builder: (context) {
                                    return CustomDialog(
                                        context: bigContext,
                                        height: 400,
                                        width: 600,
                                        targetWidgetContext: ctxt,
                                        enableArrow: true,
                                      // showOverFlowArrow: false,
                                        alignTargetWidget: AlignTargetWidget.right,
                                        child: Container(
                                          color: Colors.green,
                                        ));
                                  });
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.orange,
                              child: Text('test')));
                      }
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
