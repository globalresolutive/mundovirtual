// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gromartstore/constants.dart';
import 'package:gromartstore/model/WithdrawHistoryModel.dart';
import 'package:gromartstore/services/helper.dart';

class HistoryDetails extends StatefulWidget {
  WithdrawHistoryModel withdrawHistoryModel;

  HistoryDetails(this.withdrawHistoryModel, {Key? key}) : super(key: key);

  @override
  State<HistoryDetails> createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'withdrawalDetails'.tr(),
          style: TextStyle(
            color: isDarkMode(context) ? Color(0xFFFFFFFF) : Color(0Xff333333),
          ),
        ),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 480,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  getTextBuild('amount'.tr(), '$symbol${widget.withdrawHistoryModel.amount}'),
                  getTextBuild('date'.tr(), "${DateFormat('MMM dd, yyyy, KK:mma').format(widget.withdrawHistoryModel.paidDate.toDate()).toUpperCase()}"),
                  getTextBuild('status'.tr(), "${widget.withdrawHistoryModel.paymentStatus}"),
                  Visibility(visible: widget.withdrawHistoryModel.note.isNotEmpty, child: getTextBuild('Notes', "${widget.withdrawHistoryModel.note}")),
                  Visibility(
                      visible: widget.withdrawHistoryModel.adminNote.isNotEmpty, child: getTextBuild('Admin Note', "${widget.withdrawHistoryModel.adminNote}")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getTextBuild(String s, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          Text(
            s,
            style: TextStyle(fontFamily: 'Poppinsm', fontSize: 18, color: isDarkMode(context) ? Colors.white : Colors.black),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(fontFamily: 'Poppinsr', fontSize: 16, color: Color(COLOR_PRIMARY)),
          )
        ],
      ),
    );
  }
}
