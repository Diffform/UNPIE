context("Test of required specs are fulfilled")

test_that("01 FV single payment nominal", {
  A = fv(rate=0.04,inflation=.00, nper=35,pv=-1000,pmt=0,pmtinfladj=FALSE, pmtUltimo=TRUE)
  expect_equal(A[35],3946.08899421194)
})

test_that("02 FV single payment adj. for infl", {
  A = fv(rate=0.04,inflation=.00, nper=35,pv=-1000,pmt=0,pmtinfladj=FALSE, pmtUltimo=TRUE)
  B = fv(rate=0.04,inflation=.02, nper=35,pv=-1000,pmt=0,pmtinfladj=FALSE, pmtUltimo=TRUE)
  a=fv.single(0.04,0,35,-1000)
  b=fv.single(0.04,0.02,35,-1000)

  expect_equal(A[35],3946.08899421194)
  expect_equal(B[35],1973.15346187919)
  expect_equal(B,infladj(a,0.02))
  expect_equal(B,b)
})

test_that("03 FV annuity nominal", {
  A = fv(rate=0.04,inflation=.0, nper=35,pv=0,pmt=-1000,pmtinfladj=FALSE, pmtUltimo=TRUE)
  B = fv.annuity(rate=0.04,inflation=.0, nper=35,pmt=-1000,pmtinfladj=FALSE, pmtUltimo=TRUE)
  expect_equal(A[35],73652.2248552986)
  expect_equal(B[35],73652.2248552986)

})

test_that("04 FV const. ann. adj. for infl.", {
  A = fv(rate=0.04,inflation=.02, nper=35,pmt=-1000,pmtinfladj=FALSE, pmtUltimo=TRUE)
  B = fv.annuity(rate=0.04,inflation=.02, nper=35,pmt=-1000,pmtinfladj=FALSE, pmtUltimo=TRUE)
  expect_equal(A[35],36828.1462129973)
  expect_equal(B[35],36828.1462129973)
})

test_that("05 FV real ann. adj. for infl.", {
  A = fv(rate=0.04,inflation=.02, nper=35,pv=0,pmt=-1000,pmtinfladj=TRUE, pmtUltimo=TRUE)
  B = fv.annuity(rate=0.04,inflation=.02, nper=35,pmt=-1000,pmtinfladj=TRUE, pmtUltimo=TRUE)

  #FV(payments), not adj. for inflation
  pmt_infladj=fv.single(0.02,0,35,-1000/1.02)
  a=fv.annuity(rate=0.04,inflation=0.0, nper=35,pmt=-pmt_infladj,pmtinfladj=FALSE, pmtUltimo=TRUE)

  expect_equal(A[35],49630.82656) #FV(payments), adj. for inflation
  expect_equal(B[35],49630.82656) #FV(payments), adj. for inflation
  expect_equal(a[35],97309.9720774742) #FV(payments), not adj. for inflation
})

test_that("06 PV of annuity nominal", {
  A = pv.annuity(rate=0.04,inflation=0, nper=30,pmt=-1000,pmtinfladj=FALSE, pmtUltimo=TRUE)
  B = pv(rate=0.04,inflation=0, nper=30,fv=0,pmt=-1000,pmtinfladj=FALSE, pmtUltimo=TRUE)
  expect_equal(A[30],17292.033300665)
  expect_equal(B[30],17292.033300665)
})

test_that("07 PV of real ann. adj. for infl", {
  realRate = rate.real(0.04,0.02)
  A = pv.annuity(rate=realRate,0,30,-1000,FALSE,FALSE) #PV(payments), adj. for inflation
  B = pv.annuity(rate=0.04,0,30,-1000,FALSE,FALSE) # PV(payments), not adj. for inflation
  C = fv.single(0.02,0,30,-1000/(1.02)) #Spending per year (adj. for inflation)
  d=ts(c(1000,1020,1040.4,1061.208,1082.43216,1104.080803,1126.162419,1148.685668,1171.659381,1195.092569,
       1218.99442,1243.374308,1268.241795,1293.60663,1319.478763,1345.868338,1372.785705,1400.241419,1428.246248,
       1456.811173,1485.947396,1515.666344,1545.979671,1576.899264,1608.437249,1640.605994,1673.418114,1706.886477,1741.024206,  1775.84469))

  expect_equal(A[30],22517.6938677225)
  expect_equal(B[30],17292.0333006645)
  expect_equal(C,d)
})

test_that("08 Link savings -> withdrawals", {
  fv1=fv(rate=0.04,inflation=.02, nper=35,pv=0,pmt=-1000,pmtinfladj=TRUE, pmtUltimo=TRUE)[35]
  fv2=fv.annuity(rate=0.04,inflation=.02, nper=35,pmt=-1000,pmtinfladj=TRUE, pmtUltimo=TRUE)[35]
  pmt1=pmt(rate = 0.04, inflation = 0.02, nper = 30, fv= fv1)
  pmt2=pmt(rate = 0.04, inflation = 0.02, nper = 30, fv= fv2)
  expect_equal(pmt1[1],2204.08123706578)
  expect_equal(pmt2[30],2204.08123706578)
})

test_that("09 Link withdrawals -> savings", {
  realRate = rate.real(0.04,0.02)
  pmt=-2204.08123706578
  pv1=pv(rate=realRate,inflation=0, nper=30,fv=0,pmt=pmt,pmtinfladj=FALSE, pmtUltimo=TRUE)[30]
  pv2=pv.annuity(rate=realRate,inflation=0, nper=30,pmt=pmt,pmtinfladj=FALSE, pmtUltimo=TRUE)[30]
  pv1a=pv.single(realRate,0,35,-pv1)
  pv2a=pv.single(realRate,0,35,-pv2)

  pmt1=pmt(rate = 0.04, inflation = 0.02, nper = 35, fv = pv1a[35])
  pmt2=pmt(rate = 0.04, inflation = 0.02, nper = 35, fv = pv2a[35])

  expect_equal(pv1,49630.826555838300)
  expect_equal(pv2,49630.826555838300)
  expect_equal(pv1a[35],25153.049428082089)
  expect_equal(pv2a[35],25153.049428082089)
  expect_equal(pmt1,ts(rep(1000,35)))
  expect_equal(pmt2,ts(rep(1000,35)))
})


