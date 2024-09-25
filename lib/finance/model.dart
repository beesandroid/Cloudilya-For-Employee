class FinancePayIncometax {
  final String payType;
  final double total;
  final double firstMonth;
  final double secondMonth;
  final double thirdMonth;
  final double fourthMonth;
  final double fifthMonth;
  final double sixthMonth;
  final double seventhMonth;
  final double eighthMonth;
  final double ninthMonth;
  final double tenthMonth;
  final double leventhMonth;
  final double twelfthMonth;

  FinancePayIncometax({
    required this.payType,
    required this.total,
    required this.firstMonth,
    required this.secondMonth,
    required this.thirdMonth,
    required this.fourthMonth,
    required this.fifthMonth,
    required this.sixthMonth,
    required this.seventhMonth,
    required this.eighthMonth,
    required this.ninthMonth,
    required this.tenthMonth,
    required this.leventhMonth,
    required this.twelfthMonth,
  });

  factory FinancePayIncometax.fromJson(Map<String, dynamic> json) {
    return FinancePayIncometax(
      payType: json['payType'],
      total: json['total'],
      firstMonth: json['firstMonth'],
      secondMonth: json['secondMonth'],
      thirdMonth: json['thirdMonth'],
      fourthMonth: json['fourthMonth'],
      fifthMonth: json['fifthMonth'],
      sixthMonth: json['sixthMonth'],
      seventhMonth: json['seventhMonth'],
      eighthMonth: json['eighthMonth'],
      ninthMonth: json['ninthMonth'],
      tenthMonth: json['tenthMonth'],
      leventhMonth: json['leventhMonth'],
      twelfthMonth: json['twelfthMonth'],
    );
  }
}

class FinancePayIncometaxDetail {
  final String sectionName;
  final String deductionName;
  final double usage;
  final double less;

  FinancePayIncometaxDetail({
    required this.sectionName,
    required this.deductionName,
    required this.usage,
    required this.less,
  });

  factory FinancePayIncometaxDetail.fromJson(Map<String, dynamic> json) {
    return FinancePayIncometaxDetail(
      sectionName: json['sectionName'],
      deductionName: json['deductionName'],
      usage: json['usage'],
      less: json['less'],
    );
  }
}

class TaxSlab {
  final String slab;
  final double amount;
  final double totalTax;
  final double cess;
  final double grossIncomeTax;

  TaxSlab({
    required this.slab,
    required this.amount,
    required this.totalTax,
    required this.cess,
    required this.grossIncomeTax,
  });

  factory TaxSlab.fromJson(Map<String, dynamic> json) {
    return TaxSlab(
      slab: json['slab'],
      amount: json['amount'],
      totalTax: json['totalTax'],
      cess: json['cess'],
      grossIncomeTax: json['grossincomeTax'],
    );
  }
}
