-- parameter type deduction in 9.0+
do language plv8 $$
  plv8.execute("SELECT count(*) FROM pg_class WHERE oid = $1", ["1259"]);
  var plan = plv8.prepare("SELECT * FROM pg_class WHERE oid = $1");
  var res = plan.execute(["1259"]).shift().relname;
  plv8.elog(INFO, res);
  var cur = plan.cursor(["2610"]);
  var res = cur.fetch().relname;
  plv8.elog(INFO, res);
  cur.close();
  plan.free();
$$;

-- Show variadic argument handling
do language plv8 $$
   plv8.elog(INFO, JSON.stringify(plv8.execute("SELECT $1", 1)));
   plv8.elog(INFO, JSON.stringify(plv8.execute("SELECT $1", [1])));
   plv8.elog(INFO, JSON.stringify(plv8.execute("SELECT $1 a, $2 b", 1, 2)));

   var plan = plv8.prepare("SELECT $1 a, $2 b")

   plv8.elog(INFO, JSON.stringify(plan.execute(1, 2)));
   plv8.elog(INFO, JSON.stringify(plan.execute([1, 2])));
$$;

-- Negative cases that trigger errors.

do language plv8 $$
   plv8.execute("SELECT $1 a, $2 b", 1, 2, 3);
$$;

do language plv8 $$
   plv8.execute("SELECT $1 a, $2 b", [1, 2, 3]);
$$;

do language plv8 $$
   var plan = plv8.prepare("SELECT $1 a, $2 b")
   plan.execute([1, 2, 3]);
$$;

do language plv8 $$
   var plan = plv8.prepare("SELECT $1 a, $2 b");
   plan.execute(1, 2, 3);
$$;
