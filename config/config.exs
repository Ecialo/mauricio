import Config

config :mauricio,
  max_karma: 10,
  default_name: "Мяурицио",
  text: %{
    attracted: "Мурмурмур",
    banished: """
    <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> даёт дёру от <%= Member.full_name(who) %>.</i>
    """,
    start: """
    <i>У вас завелся котик. Сейчас он тихо сидит в уголке.
    Как его зовут?</i>
    """,
    name_cat: """
    <i><%= Cat.get_cat_name_template(cat, :dative) %> нравится имя <%= cat.name %>.</i>
    """,
    noname_cat: """
    <i>Котик решил, что будет зваться <%= cat.name %>.</i>
    """,
    already_cat: "<i>У вас уже есть котик!</i>",
    away_pet: """
    <i><%= Member.full_name(who) %> хочет погладить <%= Cat.get_cat_name_template(cat, :accusative) %>, но обнаруживает, что того нет дома.</i>
    """,
    awake_pet: """
    <i><%= Member.full_name(who) %> гладит <%= Cat.get_cat_name_template(cat, :accusative) %>.</i>
    """,
    bad_pet: [
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> недоволен и цапает <%= Member.full_name(who) %> за палец.</i>
      ШШШШ.
      """,
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> яростно дерется лапой.</i>",
      """
      <i>Когда <%= Member.full_name(who) %> пытается погладить <%= Cat.get_cat_name_template(cat, :accusative) %>, тот прогибает спину и не дает прикоснуться.</i>
      """,
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> изо всех сил отпинывается от рук <%= Member.full_name(who) %> задними лапами.</i>
      """
    ],
    joyful_pet: """
    <i><%= Member.full_name(who) %> гладит <%= Cat.get_cat_name_template(cat, :accusative) %>.</i>
    Мурррррррр.
    """,
    sad_pet: "Мямямяууууу...",
    sleep_pet: """
    <i><%= Member.full_name(who) %> гладит спящего <%= Cat.get_cat_name_template(cat, :accusative) %>.</i>
    """,
    hug_away: """
    <i><%= Member.full_name(who) %> хочет обнять <%= Cat.get_cat_name_template(cat, :accusative) %>, но того нет дома.</i>
    """,
    hug: """
    <i><%= Member.full_name(who) %> обнимает <%= state %> <%= Cat.get_cat_name_template(cat, :accusative) %>.
    <%= cat.name %> <%= cat_action %>. Навскидку <%= Cat.get_cat_name_template(cat, :nominative) %> весит </i><b><%= cat.weight %></b><i> кило и, кажется, <%= cat_dynamic %>.
    <%= Cat.get_cat_name_template(cat, :nominative, true) %> <%= laziness %>
    </i>
    """,
    become_lazy: """
    Вы чувствуете, как <%= Cat.get_cat_name_template(cat, :nominative) %> стал ещё ленивее.
    """,
    over_lazy: """
    Ленивей этому <%= Cat.get_cat_name_template(cat, :dative) %> уже не стать!
    """,
    become_annoying: """
    Вы чувствуете, как <%= Cat.get_cat_name_template(cat, :accusative) %> стал ещё надоедливей.
    """,
    over_annoying: """
    Надоедливей этому <%= Cat.get_cat_name_template(cat, :dative) %> уже не стать!
    """,
    mew: [
      "МЯУ!",
      "Мяу!",
      "Мяяяяу",
      "Мияу",
      "Мау!",
      "МААААУ!",
      "Меяу",
      "Мурр! Мафф!",
      "Ня",
      "Няяяяяя",
      "Няняияу",
      "Мямяу!",
      "Мррр!"
    ],
    aggressive: [
      "ШШШшШшШ!!!",
      "ШшШшШшШшшшшш!",
      "МмшшшШШШШ!",
      "Шшшшшшшшшшшшш....",
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> утробно рычит на <%= Member.full_name(who) %>.</i>
      """,
      "ХСССССССС!!!",
      "У-у-у-рррррр! ШШ!",
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> дерется и норовит укусить!</i>",
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> рычит и убегает под диван.</i>"
    ],
    sleep: [
      "Хрррр-Хрррр",
      "Хр-Хр-Хр",
      "ХРРРРРРРРРР!",
      "Хрррхррвап...",
      "ХррХррр",
    ],
    wake_up_lazy: "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> проснулся, но только для того, чтобы пожрать.</i>",
    wake_up_active:
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> проснулся, потянулся и снова готов носиться по комнате.</i>",
    satiety: %{
      0 => [
        "ОМНОМНОМНОМНОМНОМНОМ!!!",
        "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> заточил всю еду в мгновение ока.</i>",
        "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> слопал еду и даже кормушку слегка погрыз!</i>",
      ],
      1 => [
        "<i>Громко мурча и чавкая, <%= Cat.get_cat_name_template(cat, :nominative) %> уплетает свою еду, а потом вылизывает кормушку.</i>",
        "НЯМ-НЯМ-НЯМ!"
      ],
      2 => [
        "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> навернул от души!</i>",
        "Хрум-хрум-хрум"
      ],
      3 => [
        "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> покушал и очень этим доволен.</i>",
        "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> трескает с большим удовольствием.</i>"
      ],
      4 => "Чавк-чавк-чавк!",
      5 => "<i><i><%= Cat.get_cat_name_template(cat, :nominative, true) %> хорошо перекусил.</i>",
      6 => "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> поел.</i>",
      7 => "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> все еще делает вид, что ему вкусно.</i>",
      8 => "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> без особого энтузиазма съедает свой корм.</i>",
      9 => "<i>В котика едва лезет!</i>",
      10 => [
        "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> долго принюхивается и зарывает кормушку.</i>",
        """
        <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> не притрагивается к еде и смотрит на <%= if not is_atom(who) do Member.full_name(who) else "кормушку" end %> тяжелым взглядом, полным бесконечного презрения.</i>
        """,
      ],
      vomit: """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> съел слишком много, и его стошнило. <%= if not is_atom(who) do Member.full_name(who) <> ", это твоя вина!" else "В этом явно виноват только он сам." end %></i>
      """
    },
    stop: "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> выпрыгнул с балкона и убежал.</i>",
    food_to_feeder: """
    <i><%= Member.full_name(who) %> добавляет</i> <b><%= new_food %></b> <i>в кормушку.</i>
    """,
    feeder_overflow: """
    <i>Так как кормушка была переполнена, из неё вывалился недоеденный корм, а именно </i> <b><%= old_food %>.</b>
    """,
    feeder_content: """
    <i>В кормушке сейчас <%= if length(all_food) == 1 do "лежит" else "ровными слоями лежат" end %></i> <b><%= Enum.join(all_food, ", ") %>.</b>
    """,
    added_nothing: """
    <i><%= Member.full_name(who) %> только делает вид, что что-то добавляет в кормушку. В глазах <%= Cat.get_cat_name_template(cat, :accusative) %> недоумение и разочарование.</i>
    """,
    added_self: """
    <i><%= Member.full_name(who) %> пытается добавить в кормушку самого <%= Cat.get_cat_name_template(cat, :accusative) %>! Какой ужас!</i>
    """,
    fall_asleep: [
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> сладко уснул на диване, выставив теплое пузико напоказ.</i>",
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> заснул и теперь дёргает лапками и ушами. Кажется, ему что-то снится.</i>",
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> свернулся клубочком и закрыл нос пушистым хвостом.</i>",
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> распластался в пятне солнечного света и сладко посапывает во сне.</i>",
      "<i>От громкого храпа котика дрожат оконные рамы!</i>",
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> устроился прямо на лучших штанах <%= Member.full_name(who) %> и равномерно покрыл их своей шерстью.</i>
      """,
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> спит на коленях <%= Member.full_name(who) %> и пускает слюни.</i>
      """,
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> уснул в позе "Будда Конасана".</i>
      """,
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> ложится спать</i>"
    ],
    going_out:
      "<i><%= Cat.get_cat_name_template(cat, :dative) %> наскучило сидеть дома, и <%= Cat.get_cat_name_template(cat, :nominative) %> вышел на улицу прогуляться.</i>",
    want_care: [
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> трется о ногу <%= Member.full_name(who) %> и мурчит.</i>
      """,
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> настойчиво следует за <%= Member.full_name(who) %>.</i>
      """,
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> громко мяукает в другой комнате.</i>",
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> принес к ногам <%= Member.full_name(who) %> мышь... игрушечную, к счастью.</i>
      """,
      """
      <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> кружит вокруг <%= Member.full_name(who) %>.</i>
      """,
      "<i><%= Cat.get_cat_name_template(cat, :nominative, true) %> зазывно мяучит.</i>"
    ],
    sad: "Мямямяууууу...",
    cat_is_back: "<%= Cat.get_cat_name_template(cat, :nominative, true) %> вернулся домой.",
    feeder_consume: """
    <i><%= Cat.get_cat_name_template(cat, :nominative, true) %> съедает из кормушки</i> <b><%= food %>.</b>
    """,
    laziness: %{
      1 => "сама надоедливость!",
      2 => "фантастически надоедлив!",
      4 => "очень надоедлив!",
      8 => "весьма надоедлив.",
      16 => "немного надоедлив.",
      32 => "слегка надоедлив.",
      64 => "слегка ленив.",
      128 => "немного ленив.",
      256 => "весьма ленив.",
      512 => "очень ленив!",
      1024 => "фантастически ленив!",
    },
    help: """
    Это котик в телеграме! Кормите, гладьте и обнимайте его! Окутайте его любовью, и он ответит вам взаимностью.
    Наиболее полно раскрывает себя в чатах на несколько человек.
    Если вас раздражают комментарии кота на ваши сообщения, то котика можно прогнать, сказав «брысь». Чтобы вернуть всё как было, скажите «кскскс» :о)
    Если кот проявляет себя слишком часто или, наоборот, слишком редко, то это можно отрегулировать командами /become_lazy и /become_annoying.
    """,
    cat_name: %{
      nominative: [
        "кот",
        "котик",
        "котяра",
        "котофан",
        "котейка",
        "<%= cat.name %>"
      ],
      dative: [
        "коту",
        "котику",
        "котяре",
        "котофану",
        "котейке"
      ],
      accusative: [
        "кота",
        "котика",
        "котяру",
        "котофана",
        "котейку"
      ]
    }
  },
  triggers: %{
    attract: ["кс", "кис"],
    banish: ["брысь"],
    eat: ["жр", "съе", "куш"],
    mew: ["ня", "мя", "мур"],
    cat: ["кис", "кот", "кош", "кыс"],
    dog: ["пес", "пёс", "соб", "щен", "барб"]
  },
  schedule: %{
    tire: 3,
    hungry: 7,
    metabolic: 11,
    pine: 5
  }

import_config "#{Mix.env()}.exs"

if Mix.env() != :prod do
  import_config "secret.exs"
end
