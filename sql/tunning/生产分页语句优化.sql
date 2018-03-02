刚刚上线的SQL执行了500多秒,导致版本回滚了,同事找到我让我看看这个SQL怎么优化...

SQL如下:
select tmp_page.*, rownum row_id
  from (select *
          from (select question.id as id,
                       question.user_id as userid,
                       question.id_live_room as channelid,
                       question.question_answers_id as commentid,
                       question.parent_question_answers_id as parentcommentid,
                       question.question_answers_content as commentcontent,
                       question.whether_show_good_comment as whethershowgoodcomment,
                       question.whether_reply as commentstatus,
                       to_char(question.created_date, 'yyyy-mm-dd hh24:mi:ss') as createddate,
                       question.created_by as createdby,
                       to_char(question.updated_date, 'yyyy-mm-dd hh24:mi:ss') as updateddate,
                       question.updated_by as updatedby,
                       to_char(question.reply_date, 'yyyy-mm-dd hh24:mi:ss') as replydate,
                       (select oml.room_name
                          from omm_mop_liveroom_info oml
                         where oml.id_liveroom = question.id_live_room) roomname,
                       (select count(wc.id_wcoupon)
                          from omm_mop_winning_coupon wc
                         where wc.attribute1 = question.id) as usecoupon,
                       answers.user_id as replyuserid,
                       answers.question_answers_id as replycommentid,
                       question.whether_reply as replaystatus,
                       nvl(answers.question_answers_content, '--') as replycommentcontent,
                       (select count(question.id)
                          from sis_live_question_answers t1,
                               sis_live_question_answers t2
                         where t2.parent_question_answers_id =
                               t1.question_answers_id
                           and t2.question_answers_id =
                               question.question_answers_id
                           and t2.user_id in
                               (select ru.user_id
                                  from omm_mop_user_role ru
                                 where ru.is_liveroom = '01')) as cts
                  from sis_live_question_answers question,
                       sis_live_question_answers answers
                 where answers.parent_question_answers_id(+) =
                       question.question_answers_id
                   and question.id_live_room in
                       ('20160823534eecada8a545b98417d735e43a512f',
                        '20160826c8748a485cb04b61aaa6ad88f103b37f')
                   and question.created_date is not null
                 order by question.created_date desc) temp
         where temp.cts = 0) tmp_page
 where rownum <= 10
