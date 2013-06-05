require 'spec_helper'

describe VisualizationsController do
  describe "#results_to_datatable" do
    let!(:suite)        { create(:suite) }
    let!(:students)     { create_list(:student, 2) }
    let!(:participants) { students.collect { |s| create(:participant, suite: suite, student: s) } }
    let!(:evaluations)  { create_list(:suite_evaluation, 2, suite: suite, max_result: 10, red_below: 4, green_above: 7) }
    let!(:result_s1_e1) { create(:result, evaluation: evaluations.first,  student: students.first,  value: 4) }
    let!(:result_s1_e2) { create(:result, evaluation: evaluations.second, student: students.first,  value: 5) }
    let!(:result_s2_e1) { create(:result, evaluation: evaluations.first,  student: students.second, value: 6) }
    let!(:result_s2_e2) { create(:result, evaluation: evaluations.second, student: students.second, value: 7) }

    subject(:table) { controller.send(:results_to_datatable, evaluations) }

    it { should have(3).items }

    context "title row" do
      subject { table.first }
      it { should have(3).items }
      its(:first)  { should == Evaluation.model_name.human(count: 2) }
      its(:second) { should == students.first.name }
      its(:third)  { should == students.second.name }
    end

    context "row for evaluation 1" do
      subject { table.second }
      it { should have(3).items }
      its(:first)  { should == evaluations.first.name }
      its(:second) { should == result_s1_e1.value.to_f / 10.0 }
      its(:third)  { should == result_s2_e1.value.to_f / 10.0 }
    end

    context "row for evaluation 2" do
      subject { table.third }
      it { should have(3).items }
      its(:first)  { should == evaluations.second.name }
      its(:second) { should == result_s1_e2.value.to_f / 10.0 }
      its(:third)  { should == result_s2_e2.value.to_f / 10.0 }
    end

    context "limited by student" do
      let(:table) { controller.send(:results_to_datatable, evaluations, students.first) }

      context "title row" do
        subject { table.first }
        it { should have(2).items }
        its(:first)  { should == Evaluation.model_name.human(count: 2) }
        its(:second) { should == students.first.name }
      end

      context "row for evaluation 1" do
        subject { table.second }
        it { should have(2).items }
        its(:first)  { should == evaluations.first.name }
        its(:second) { should == result_s1_e1.value.to_f / 10.0 }
      end

      context "row for evaluation 2" do
        subject { table.third }
        it { should have(2).items }
        its(:first)  { should == evaluations.second.name }
        its(:second) { should == result_s1_e2.value.to_f / 10.0 }
      end
    end
  end

  describe "#result_colors_to_datatable" do
    let!(:suite)        { create(:suite) }
    let!(:students)     { create_list(:student, 2) }
    let!(:participants) { students.collect { |s| create(:participant, suite: suite, student: s) } }
    let!(:evaluations)  { create_list(:suite_evaluation, 3, suite: suite, max_result: 10, red_below: 4, green_above: 7) }
    let!(:result_s1_e1) { create(:result, evaluation: evaluations.first,  student: students.first,  value: 3) }
    let!(:result_s1_e2) { create(:result, evaluation: evaluations.second, student: students.first,  value: 5) }
    let!(:result_s2_e1) { create(:result, evaluation: evaluations.first,  student: students.second, value: 6) }
    let!(:result_s2_e2) { create(:result, evaluation: evaluations.second, student: students.second, value: 8) }

    subject(:table) { controller.send(:result_colors_to_datatable, evaluations) }

    it { should have(4).items }

    context "title row" do
      subject      { table.first }
      it           { should have(4).items }
      its(:first)  { should == Evaluation.model_name.human(count: 2) }
      its(:second) { should == I18n.t(:red) }
      its(:third)  { should == I18n.t(:yellow) }
      its(:fourth) { should == I18n.t(:green) }
    end

    context "row for evaluation 1" do
      subject      { table.second }
      it           { should have(4).items }
      its(:first)  { should == evaluations.first.name }
      its(:second) { should == evaluations.first.result_distribution[:red] }
      its(:third)  { should == evaluations.first.result_distribution[:yellow] }
      its(:fourth) { should == evaluations.first.result_distribution[:green] }
    end
    context "row for evaluation 2" do
      subject      { table.third }
      it           { should have(4).items }
      its(:first)  { should == evaluations.second.name }
      its(:second) { should == evaluations.second.result_distribution[:red] }
      its(:third)  { should == evaluations.second.result_distribution[:yellow] }
      its(:fourth) { should == evaluations.second.result_distribution[:green] }
    end
    context "row for evaluation 3" do
      subject      { table.fourth }
      it           { should have(4).items }
      its(:first)  { should == evaluations.third.name }
      its(:second) { should == 0 }
      its(:third)  { should == 0 }
      its(:fourth) { should == 0 }
    end
  end

  describe "#result_stanines_to_datatable" do
    let!(:suite)        { create(:suite) }
    let!(:students)     { create_list(:student, 3) }
    let!(:participants) { students.collect { |s| create(:participant, suite: suite, student: s) } }
    let!(:evaluations)  { create_list(:suite_evaluation, 2,
      suite: suite,
      max_result: 8,
      red_below: 4,
      green_above: 6,
      stanine_values: [ 0, 1, 2, 3, 4, 5, 6, 7 ]
    ) }

    before(:each) do
      [ 3, 3, 5 ].each do |value|
        create(:result, evaluation: evaluations.first, value: value)
      end
      [ 4, 4, 5 ].each do |value|
        create(:result, evaluation: evaluations.second, value: value)
      end
    end

    subject(:table) { controller.send(:result_stanines_to_datatable, evaluations) }

    it { should have(10).items }

    context "title row" do
      subject      { table.first }
      it           { should have(4).items }
      its(:first)  { should == I18n.t(:stanine) }
      its(:second) { should == I18n.t(:normal_distribution) }
      its(:third)  { should == evaluations.first.name }
      its(:fourth) { should == evaluations.second.name }
    end

    [
      [1, 0.04 * 3.0, 0, 0],
      [2, 0.07 * 3.0, 0, 0],
      [3, 0.12 * 3.0, 0, 0],
      [4, 0.17 * 3.0, 2, 0],
      [5, 0.20 * 3.0, 0, 2],
      [6, 0.17 * 3.0, 1, 1],
      [7, 0.12 * 3.0, 0, 0],
      [8, 0.07 * 3.0, 0, 0],
      [9, 0.04 * 3.0, 0, 0],
    ].each do |row, expected_second, expected_third, expected_fourth|
      context "row #{row}" do
        subject      { table[row] }
        it           { should have(4).items }
        its(:first)  { should == row.to_s }
        its(:second) { should == expected_second }
        its(:third)  { should == expected_third }
        its(:fourth) { should == expected_fourth }
      end
    end
  end
end
