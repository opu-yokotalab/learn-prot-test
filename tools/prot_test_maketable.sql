create table examination (
user_id	text,
test_id	text,
group_id	text,
group_mark	text,
ques_id	text,
ques_pass	text,
test_key	text,
time	timestamp without time zone,
examination_pkey	text not null	primary key
);

create table pre_evaluate (
chk_selection	text,
eval_result	text,
total_point	text,
comp_eval	boolean,
crct_total_weight	text,
incrct_total_weight	text,
total_weight	text,
time	timestamp without time zone,
eval_key	text,
evaluate_pkey	text not null	primary key
);